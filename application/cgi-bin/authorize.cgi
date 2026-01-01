#!/usr/bin/env python3
import cgi
import cgitb
import psycopg2
import html
import login

cgitb.enable()

print("Content-Type: text/html\n")

form = cgi.FieldStorage()
action = form.getfirst("action", "list")

connection = psycopg2.connect(
    host=login.host,
    database=login.database,
    user=login.user,
    password=login.password
)
cursor = connection.cursor()

# create table if it does not exist
cursor.execute("""
    CREATE TABLE IF NOT EXISTS reservation_authorization (
        start_date DATE,
        end_date DATE,
        country TEXT,
        cni TEXT,
        sailor_cni TEXT,

        PRIMARY KEY (start_date, end_date, country, cni, sailor_cni),

        FOREIGN KEY (start_date, end_date, country, cni)
            REFERENCES reservation(start_date, end_date, country, cni)
            ON DELETE CASCADE,

        FOREIGN KEY (sailor_cni)
            REFERENCES sailor(cni)
            ON DELETE CASCADE
    );
""")
connection.commit()

# add authorisation
if action == "add":
    try:
        cursor.execute("""
            INSERT INTO reservation_authorization
            (start_date, end_date, country, cni, sailor_cni)
            VALUES (%s, %s, %s, %s, %s);
        """, (
            form.getfirst("start_date"),
            form.getfirst("end_date"),
            form.getfirst("country"),
            form.getfirst("cni"),
            form.getfirst("sailor_cni")
        ))

        connection.commit()

    except Exception as e:
        connection.rollback()
        print(f"<p>Error: {html.escape(str(e))}</p>")

    print("Status: 303 See Other")
    print("Location: authorizations.cgi\n")

# remove authorisation
elif action == "remove":
    cursor.execute("""
        DELETE FROM reservation_authorization
        WHERE start_date=%s AND end_date=%s
          AND country=%s AND cni=%s AND sailor_cni=%s;
    """, (
        form.getfirst("start_date"),
        form.getfirst("end_date"),
        form.getfirst("country"),
        form.getfirst("cni"),
        form.getfirst("sailor_cni")
    ))

    connection.commit()

    print("Status: 303 See Other")
    print("Location: authorizations.cgi\n")

# list authorisations
else:
    cursor.execute("""
        SELECT ra.start_date, ra.end_date, ra.country, ra.cni,
               s.cni, s.name
        FROM reservation_authorization ra
        JOIN sailor s ON s.cni = ra.sailor_cni
        ORDER BY ra.start_date DESC;
    """)

    rows = cursor.fetchall()

    print("""
    <html>
    <head><title>Authorizations</title></head>
    <body>
    <h1>Reservation Authorizations</h1>

    <h2>Authorize sailor</h2>
    <form method="post">
        <input type="hidden" name="action" value="add">
        Start date: <input name="start_date" required><br>
        End date: <input name="end_date" required><br>
        Country: <input name="country" required><br>
        Boat CNI: <input name="cni" required><br>
        Sailor CNI: <input name="sailor_cni" required><br>
        <input type="submit" value="Authorize">
    </form>

    <h2>Current authorizations</h2>
    <table border="1">
        <tr>
            <th>Start</th>
            <th>End</th>
            <th>Country</th>
            <th>Boat CNI</th>
            <th>Sailor</th>
            <th>Action</th>
        </tr>
    """)

    for r in rows:
        print(f"""
        <tr>
            <td>{r[0]}</td>
            <td>{r[1]}</td>
            <td>{html.escape(r[2])}</td>
            <td>{html.escape(r[3])}</td>
            <td>{html.escape(r[5])} ({r[4]})</td>
            <td>
                <form method="post">
                    <input type="hidden" name="action" value="remove">
                    <input type="hidden" name="start_date" value="{r[0]}">
                    <input type="hidden" name="end_date" value="{r[1]}">
                    <input type="hidden" name="country" value="{r[2]}">
                    <input type="hidden" name="cni" value="{r[3]}">
                    <input type="hidden" name="sailor_cni" value="{r[4]}">
                    <input type="submit" value="De-authorise">
                </form>
            </td>
        </tr>
        """)

    print("""
    </table>
    </body>
    </html>
    """)

cursor.close()
connection.close()
