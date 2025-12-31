#!/usr/bin/python3
import cgi
import cgitb
import psycopg2
import login
import html
import os
from string import Template

cgitb.enable()

form = cgi.FieldStorage()
connection = None
message = ''
rows_html = ''
locations_options = ''
reservations_options = ''
skippers_options = ''

try:
    # If add form requested (link includes ?add=1) show the form template
    if 'add' in form and not form.getfirst('takeoff'):
        try:
            connection = psycopg2.connect(login.credentials)
            cursor = connection.cursor()
            
            # Get locations for dropdown
            cursor.execute('SELECT latitude, longitude, name, country_name FROM location ORDER BY name;')
            loc_rows = cursor.fetchall()
            for lat, lon, name, country in loc_rows:
                locations_options += '<option value="{},{}">{}  ({})</option>'.format(
                    lat, lon, html.escape(name or ''), html.escape(country or ''))
            
            # Get available reservations (current or future)
            cursor.execute('''
                SELECT r.start_date, r.end_date, r.country, r.cni, 
                       b.name, c.name
                FROM reservation r
                JOIN boat b ON (r.country = b.country AND r.cni = b.cni)
                JOIN country c ON b.country = c.name
                WHERE r.end_date >= CURRENT_DATE
                ORDER BY r.start_date DESC;
            ''')
            res_rows = cursor.fetchall()
            for start, end, country, cni, boat_name, country_name in res_rows:
                res_id = '{},{},{},{}'.format(start, end, country, cni)
                reservations_options += '<option value="{}">{} ({}) - {} to {}</option>'.format(
                    res_id, 
                    html.escape(boat_name or ''), 
                    html.escape(country_name or ''),
                    start, end)
            
            # Get sailors for skipper dropdown
            cursor.execute('''
                SELECT email, firstname, surname 
                FROM sailor 
                ORDER BY firstname, surname;
            ''')
            sailor_rows = cursor.fetchall()
            for email, firstname, surname in sailor_rows:
                skippers_options += '<option value="{}">{} {} ({})</option>'.format(
                    html.escape(email or ''),
                    html.escape(firstname or ''),
                    html.escape(surname or ''),
                    html.escape(email or ''))
            
            cursor.close()
            connection.close()
            
            script_dir = os.path.dirname(os.path.abspath(__file__))
            tpl_path = os.path.join(script_dir, 'templates', 'trips_form.html')
            with open(tpl_path, 'r', encoding='utf-8') as f:
                tpl = Template(f.read())
            print('Content-type: text/html\n')
            print(tpl.substitute(
                title='Add Trip',
                message='',
                locations_options=locations_options,
                reservations_options=reservations_options,
                skippers_options=skippers_options
            ))
            exit()
        except Exception as te:
            message = '<p>Template error: {}</p>'.format(html.escape(str(te)))

    # Connect to DB
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()

    # If a delete request was issued, attempt deletion
    if 'delete' in form:
        # Primary key: takeoff, reservation_start_date, reservation_end_date, boat_country, cni
        delete_data = form.getfirst('delete')  # Format: "takeoff,res_start,res_end,country,cni"
        try:
            parts = delete_data.split(',')
            if len(parts) == 5:
                takeoff, res_start, res_end, boat_country, cni = parts
                cursor.execute('''
                    DELETE FROM trip
                    WHERE takeoff = %s
                      AND reservation_start_date = %s
                      AND reservation_end_date = %s
                      AND boat_country = %s
                      AND cni = %s;
                ''', (takeoff, res_start, res_end, boat_country, cni))
                connection.commit()
                message = '<p class="success">Deleted trip starting on {}</p>'.format(html.escape(takeoff))
            else:
                message = '<p class="error">Invalid delete request</p>'
        except Exception as de:
            try:
                connection.rollback()
            except Exception:
                pass
            message = '<p class="error">Could not delete trip: {}</p>'.format(html.escape(str(de)))

    # If adding (form submitted) process new trip insertion
    if form.getfirst('takeoff'):
        takeoff = form.getfirst('takeoff')
        arrival = form.getfirst('arrival')
        from_location = form.getfirst('from_location')  # "lat,lon"
        to_location = form.getfirst('to_location')  # "lat,lon"
        skipper = form.getfirst('skipper')
        reservation = form.getfirst('reservation')  # "start,end,country,cni"
        insurance = form.getfirst('insurance')
        
        try:
            if not all([takeoff, arrival, from_location, to_location, skipper, reservation, insurance]):
                raise Exception('All fields are required')
            
            # Parse location coordinates
            from_lat, from_lon = from_location.split(',')
            to_lat, to_lon = to_location.split(',')
            
            # Parse reservation info
            res_start, res_end, boat_country, cni = reservation.split(',')
            
            # Start transaction with deferred constraints
            cursor.execute('SET CONSTRAINTS ALL DEFERRED;')
            
            cursor.execute('''
                INSERT INTO trip (
                    takeoff, arrival, insurance,
                    from_latitude, from_longitude,
                    to_latitude, to_longitude,
                    skipper,
                    reservation_start_date, reservation_end_date,
                    boat_country, cni
                ) VALUES (
                    %s, %s, %s,
                    %s, %s,
                    %s, %s,
                    %s,
                    %s, %s,
                    %s, %s
                );
            ''', (
                takeoff, arrival, insurance,
                from_lat, from_lon,
                to_lat, to_lon,
                skipper,
                res_start, res_end,
                boat_country, cni
            ))
            
            connection.commit()
            message = '<p class="success">Added trip: {} to {}</p>'.format(
                html.escape(takeoff), html.escape(arrival))
        except psycopg2.IntegrityError as ie:
            connection.rollback()
            error_msg = str(ie)
            if 'trip_takeoff_check' in error_msg or 'takeoff >= reservation_start_date' in error_msg:
                message = '<p class="error">Cannot add trip: Takeoff date must be after or equal to reservation start date (IC-4)</p>'
            elif 'overlap' in error_msg.lower():
                message = '<p class="error">Cannot add trip: This trip overlaps with another trip for the same boat (IC-2)</p>'
            else:
                message = '<p class="error">Cannot add trip: {}</p>'.format(html.escape(error_msg))
        except Exception as ae:
            connection.rollback()
            message = '<p class="error">Could not add trip: {}</p>'.format(html.escape(str(ae)))

    # Fetch all trips with related information
    sql = '''
        SELECT 
            t.takeoff,
            t.arrival,
            t.insurance,
            loc_from.name AS from_location,
            loc_to.name AS to_location,
            s.firstname || ' ' || s.surname AS skipper_name,
            t.reservation_start_date,
            t.reservation_end_date,
            t.boat_country,
            t.cni,
            b.name AS boat_name
        FROM trip t
        JOIN location loc_from ON (t.from_latitude = loc_from.latitude 
                                   AND t.from_longitude = loc_from.longitude)
        JOIN location loc_to ON (t.to_latitude = loc_to.latitude 
                                 AND t.to_longitude = loc_to.longitude)
        JOIN sailor s ON t.skipper = s.email
        JOIN boat b ON (t.boat_country = b.country AND t.cni = b.cni)
        ORDER BY t.takeoff DESC;
    '''
    cursor.execute(sql)
    rows = cursor.fetchall()

    # Build table rows HTML
    for row in rows:
        takeoff, arrival, insurance, from_loc, to_loc, skipper, \
        res_start, res_end, boat_country, cni, boat_name = row
        
        # Create delete identifier (primary key)
        delete_id = '{},{},{},{},{}'.format(takeoff, res_start, res_end, boat_country, cni)
        
        rows_html += '<tr>'
        rows_html += '<td>{}</td>'.format(html.escape(str(takeoff)))
        rows_html += '<td>{}</td>'.format(html.escape(str(arrival)))
        rows_html += '<td>{} → {}</td>'.format(
            html.escape(from_loc or ''), html.escape(to_loc or ''))
        rows_html += '<td>{}</td>'.format(html.escape(skipper or ''))
        rows_html += '<td>{} ({}/{})</td>'.format(
            html.escape(boat_name or ''), 
            html.escape(boat_country or ''), 
            html.escape(cni or ''))
        rows_html += '<td>{}</td>'.format(html.escape(insurance or ''))
        rows_html += '<td>'
        rows_html += '<form action="trips.cgi" method="post" style="display:inline;margin:0">'
        rows_html += '<input type="hidden" name="delete" value="{}"/>'.format(html.escape(delete_id))
        rows_html += '<button class="btn danger" type="submit" style="background:#e11d48;color:white;border-color:rgba(225,29,72,0.12);">Delete</button>'
        rows_html += '</form>'
        rows_html += '</td>'
        rows_html += '</tr>'

    cursor.close()
except Exception as e:
    message = '<p class="error">An error occurred: {}</p>'.format(html.escape(str(e)))
finally:
    if connection is not None:
        connection.close()

# Render template
print('Content-type: text/html\n')
try:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    tpl_path = os.path.join(script_dir, 'templates', 'trips_list.html')
    with open(tpl_path, 'r', encoding='utf-8') as f:
        tpl = Template(f.read())
    output = tpl.substitute(title='Trips', message=message, rows=rows_html)
    print(output)
except Exception as te:
    print('<html><body>')
    print('<h1>Template error</h1>')
    print('<p>{}</p>'.format(html.escape(str(te))))
    print('</body></html>')