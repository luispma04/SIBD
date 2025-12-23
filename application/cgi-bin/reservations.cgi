#!/usr/bin/env python3
import cgi
import html
import os
from application import db


def get_conn():
    return db.get_conn()


def init_db(conn):
    conn.execute('''CREATE TABLE IF NOT EXISTS reservation(
        start_date TEXT,
        end_date TEXT,
        country TEXT,
        cni TEXT,
        responsible TEXT,
        PRIMARY KEY(start_date,end_date,country,cni)
    )''')
    conn.commit()

def html_head(title="Reservations"):
    return f"""Content-Type: text/html\n\n<!doctype html>\n<html><head><meta charset='utf-8'><title>{html.escape(title)}</title>"""

def render_header():
    return ("</head><body>\n<header class=\"topbar\">\n<div class=\"brand\"><h1>Boating Management System</h1></div>\n" 
            "<nav class=\"nav\">\n" 
            "<a href=\"/index.html\">Home</a>\n" 
            "<a href=\"/cgi-bin/sailors.py?action=list\">Sailors</a>\n" 
            "<a href=\"/cgi-bin/reservations.py?action=list\">Reservations</a>\n" 
            "<a href=\"/cgi-bin/trips.py?action=list\">Trips</a>\n</nav></header>\n<main class=\"container\">\n")

def render_footer():
    return "</main></body></html>"

def list_reservations(conn):
    cur = conn.execute('SELECT start_date,end_date,country,cni,responsible FROM reservation ORDER BY start_date')
    rows = cur.fetchall()
    out = []
    out.append(html_head('Reservations'))
    out.append('<link rel="stylesheet" href="/static/style.css">')
    out.append(render_header())
    out.append('<div class="card"><h2>Reservations</h2>')
    out.append('<a class="btn" href="/cgi-bin/reservations.py?action=create">Create reservation</a>')
    out.append('<table class="table"><thead><tr><th>Start</th><th>End</th><th>Country</th><th>Boat CNI</th><th>Responsible</th><th></th></tr></thead><tbody>')
    if not rows:
        out.append('<tr><td colspan="6" class="muted">No reservations</td></tr>')
    else:
        for r in rows:
            out.append('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>' % (
                html.escape(r['start_date']), html.escape(r['end_date']), html.escape(r['country']), html.escape(r['cni']), html.escape(r['responsible'])))
            key = '?start=%s&end=%s&country=%s&cni=%s' % (html.escape(r['start_date']), html.escape(r['end_date']), html.escape(r['country']), html.escape(r['cni']))
            out.append(f'<td><a class="btn ghost" href="/cgi-bin/reservations.py?action=delete&{key[1:]}">Delete</a></td></tr>')
    out.append('</tbody></table></div>')
    out.append(render_footer())
    return '\n'.join(out)

def create_form(errors=None, values=None):
    values = values or {}
    errors = errors or []
    out = []
    out.append(html_head('Create reservation'))
    out.append('<link rel="stylesheet" href="/static/style.css">')
    out.append(render_header())
    out.append('<div class="card"><h2>Create reservation</h2>')
    if errors:
        out.append('<div class="muted">' + html.escape('; '.join(errors)) + '</div>')
    out.append('<form method="post" action="/cgi-bin/reservations.py?action=create">')
    out.append('Start date (YYYY-MM-DD):<br><input name="start_date" required value="%s"><br>' % html.escape(values.get('start_date','')))
    out.append('End date (YYYY-MM-DD):<br><input name="end_date" required value="%s"><br>' % html.escape(values.get('end_date','')))
    out.append('Country:<br><input name="country" required value="%s"><br>' % html.escape(values.get('country','')))
    out.append('Boat CNI:<br><input name="cni" required value="%s"><br>' % html.escape(values.get('cni','')))
    out.append('Responsible (senior email):<br><input name="responsible" required value="%s"><br>' % html.escape(values.get('responsible','')))
    out.append('<br><button class="btn" type="submit">Create</button> <a class="btn ghost" href="/cgi-bin/reservations.py?action=list">Cancel</a>')
    out.append('</form></div>')
    out.append(render_footer())
    return '\n'.join(out)

def confirm_delete(start,end,country,cni):
    out = []
    out.append(html_head('Delete reservation'))
    out.append('<link rel="stylesheet" href="/static/style.css">')
    out.append(render_header())
    out.append('<div class="card"><h2>Delete reservation</h2>')
    out.append(f'<div class="muted">Are you sure you want to delete reservation {html.escape(start)} to {html.escape(end)} for boat {html.escape(cni)} ({html.escape(country)})?</div>')
    out.append(f'<form method="post" action="/cgi-bin/reservations.py?action=delete&start={html.escape(start)}&end={html.escape(end)}&country={html.escape(country)}&cni={html.escape(cni)}">')
    out.append('<br><button class="btn" type="submit">Delete</button> <a class="btn ghost" href="/cgi-bin/reservations.py?action=list">Cancel</a>')
    out.append('</form></div>')
    out.append(render_footer())
    return '\n'.join(out)

def main():
    fs = cgi.FieldStorage()
    action = (fs.getfirst('action') or 'list')
    conn = get_conn()
    init_db(conn)
    try:
        if action == 'list':
            print(list_reservations(conn))
        elif action == 'create':
            if os.environ.get('REQUEST_METHOD','GET').upper() == 'POST':
                start = fs.getfirst('start_date','').strip()
                end = fs.getfirst('end_date','').strip()
                country = fs.getfirst('country','').strip()
                cni = fs.getfirst('cni','').strip()
                responsible = fs.getfirst('responsible','').strip()
                errors = []
                if not (start and end and country and cni and responsible):
                    errors.append('All fields required')
                    print(create_form(errors, {'start_date':start,'end_date':end,'country':country,'cni':cni,'responsible':responsible}))
                    return
                try:
                    conn.execute('INSERT INTO reservation(start_date,end_date,country,cni,responsible) VALUES(?,?,?,?,?)', (start,end,country,cni,responsible))
                    conn.commit()
                except db.IntegrityError:
                    errors.append('Reservation already exists')
                    print(create_form(errors, {'start_date':start,'end_date':end,'country':country,'cni':cni,'responsible':responsible}))
                    return
                print('Status: 303 See Other')
                print('Location: /cgi-bin/reservations.py?action=list\n')
            else:
                print(create_form())
        elif action == 'delete':
            start = fs.getfirst('start','')
            end = fs.getfirst('end','')
            country = fs.getfirst('country','')
            cni = fs.getfirst('cni','')
            if os.environ.get('REQUEST_METHOD','GET').upper() == 'POST':
                conn.execute('DELETE FROM reservation WHERE start_date=? AND end_date=? AND country=? AND cni=?', (start,end,country,cni))
                conn.commit()
                print('Status: 303 See Other')
                print('Location: /cgi-bin/reservations.py?action=list\n')
            else:
                print(confirm_delete(start,end,country,cni))
        else:
            print(list_reservations(conn))
    finally:
        conn.close()

if __name__ == '__main__':
    main()
