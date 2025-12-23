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
try:
    # If add form requested (link includes ?add=1) show the form template
    if 'add' in form and not form.getfirst('email'):
        try:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            tpl_path = os.path.join(script_dir, 'templates', 'sailor_form.html')
            with open(tpl_path, 'r', encoding='utf-8') as f:
                tpl = Template(f.read())
            print('Content-type: text/html\n')
            print(tpl.substitute(title='Add Sailor', message=''))
            exit()
        except Exception as te:
            # fall through and render main page with error
            message = '<p>Template error: {}</p>'.format(html.escape(str(te)))

    # Connect to DB
    connection = psycopg2.connect(login.credentials)
    cursor = connection.cursor()

    # If a delete request was issued, attempt deletion
    if 'delete' in form:
        email = form.getfirst('delete')
        try:
            # Remove dependent rows in a safe order
            # 1) For reservations where this senior is responsible, remove authorised and trips first
            cursor.execute(
                'SELECT start_date, end_date, country, cni FROM reservation WHERE responsible = %s;', (email,))
            res_rows = cursor.fetchall()
            for r in res_rows:
                sd, ed, country, cni = r
                cursor.execute(
                    'DELETE FROM authorised WHERE start_date = %s AND end_date = %s AND boat_country = %s AND cni = %s;', (sd, ed, country, cni))
                cursor.execute(
                    'DELETE FROM trip WHERE reservation_start_date = %s AND reservation_end_date = %s AND boat_country = %s AND cni = %s;', (sd, ed, country, cni))

            # 2) Delete reservations where this senior was responsible
            cursor.execute('DELETE FROM reservation WHERE responsible = %s;', (email,))

            # 3) Delete authorised rows referring to this sailor (other reservations)
            cursor.execute('DELETE FROM authorised WHERE sailor = %s;', (email,))

            # 4) Delete trips where this sailor was the skipper
            cursor.execute('DELETE FROM trip WHERE skipper = %s;', (email,))

            # 5) Sailing certificates and their valid_for entries
            cursor.execute('DELETE FROM valid_for WHERE sailor = %s;', (email,))
            cursor.execute('DELETE FROM sailing_certificate WHERE sailor = %s;', (email,))

            # 6) Remove specialization rows (junior/senior)
            cursor.execute('DELETE FROM junior WHERE email = %s;', (email,))
            cursor.execute('DELETE FROM senior WHERE email = %s;', (email,))

            # 7) Finally delete the sailor
            cursor.execute('DELETE FROM sailor WHERE email = %s;', (email,))

            connection.commit()
            message = '<p>Deleted sailor: {}</p>'.format(html.escape(email or ''))
        except Exception as de:
            try:
                connection.rollback()
            except Exception:
                pass
            message = '<h4>Could not delete sailor {}</h4><p>{}</p>'.format(html.escape(email or ''), html.escape(str(de)))

    # Fetch all sailors with their specialization (junior/senior)
    sql = '''
    SELECT s.email, s.firstname, s.surname,
           CASE WHEN j.email IS NOT NULL THEN 'junior'
                WHEN se.email IS NOT NULL THEN 'senior'
                ELSE '' END AS specialization
    FROM sailor s
    LEFT JOIN junior j ON s.email = j.email
    LEFT JOIN senior se ON s.email = se.email
    ORDER BY s.surname, s.firstname;
    '''
    cursor.execute(sql)
    rows = cursor.fetchall()

    # If adding (form submitted) process new sailor insertion
    if form.getfirst('email'):
        new_email = form.getfirst('email')
        new_first = form.getfirst('firstname')
        new_surname = form.getfirst('surname')
        new_type = form.getfirst('type')
        try:
            if not new_email:
                raise Exception('Email is required')
            cursor.execute('INSERT INTO sailor(firstname, surname, email) VALUES (%s, %s, %s);',
                           (new_first, new_surname, new_email))
            if new_type == 'junior':
                cursor.execute('INSERT INTO junior(email) VALUES (%s);', (new_email,))
            else:
                cursor.execute('INSERT INTO senior(email) VALUES (%s);', (new_email,))
            connection.commit()
            message = '<p>Added sailor: {}</p>'.format(html.escape(new_email))
        except Exception as ae:
            connection.rollback()
            message = '<h4>Could not add sailor</h4><p>{}</p>'.format(html.escape(str(ae)))

    # Build table rows HTML
    for row in rows:
        email, firstname, surname, spec = row
        e = html.escape(email or '')
        fn = html.escape(firstname or '')
        sn = html.escape(surname or '')
        sp = html.escape(spec or '')
        rows_html += '<tr>'
        rows_html += '<td>{}</td>'.format(e)
        rows_html += '<td>{}</td>'.format(fn)
        rows_html += '<td>{}</td>'.format(sn)
        rows_html += '<td>{}</td>'.format(sp)
        rows_html += '<td>'
        rows_html += '<form action="sailors.cgi" method="get" style="display:inline;margin:0">'
        rows_html += '<input type="hidden" name="delete" value="{}"/>'.format(e)
        rows_html += '<button class="btn danger" type="submit" style="background:#e11d48;color:white;border-color:rgba(225,29,72,0.12);">Delete</button>'
        rows_html += '</form>'
        rows_html += '</td>'
        rows_html += '</tr>'

    cursor.close()
except Exception as e:
    message = '<h1>An error occurred.</h1><p>{}</p>'.format(html.escape(str(e)))
finally:
    if connection is not None:
        connection.close()

# Render template
print('Content-type: text/html\n')
try:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    tpl_path = os.path.join(script_dir, 'templates', 'sailors_list.html')
    with open(tpl_path, 'r', encoding='utf-8') as f:
        tpl = Template(f.read())
    output = tpl.substitute(title='Sailors', message=message, rows=rows_html)
    print(output)
except Exception as te:
    print('<html><body>')
    print('<h1>Template error</h1>')
    print('<p>{}</p>'.format(html.escape(str(te))))
    print('</body></html>')