import smtplib
import os
import requests as reqs
import json
import urllib3
from email.mime.text import MIMEText
input = os.getenv("bitbucket_url")
hostname = str(input)
input2 = os.getenv("project_name")
project_key = str(input2)
def get_project_admin(hostname, project_key):
    url = '{hostname}/rest/api/1.0/projects/{project_key}/permissions/users?limit=99'.format(hostname=hostname,project_key=project_key)
    headers = {'Content-Type': 'application/json'}
    # params = {}
    # if limit:
    #     params['limit'] = limit
    r = reqs.get(url, auth=('smohammed', 'Mommyd@d786'), headers=headers, verify=False)
    users_dump = r.json()
    user_email = []
    files = []
    all_values = users_dump['values']
    for index in range(len(all_values)):
        admin = users_dump['values'][index]['permission']
        if admin == 'PROJECT_ADMIN' :
            user_email.append(users_dump['values'][index]['user']['emailAddress'])
    return user_email
admin_list = get_project_admin(hostname, project_key)
msg = MIMEText('Bitbucket $projectkey braches to be deleted.csv has been generated.  For status and output, please see https://jktools.tools.tsys.aws/job/getbranchesbyproject/$BUILD_NUMBER/console')
recipients = admin_list
msg['Subject'] = 'SCANNING for old branches in $project_name which are $no_day old in $bitbucket_url'
msg['From'] = 'digitaldevops@tsys.com'
msg['To'] = ", ".join(recipients)
msg['X-Priority'] = '2'
fileMsg = email.mime.base.MIMEBase()
s = smtplib.SMTP('mailrelay.qa.tpp.tsysecom.com:25')
s.sendmail('digitaldevops@tsys.com', recipients, msg.as_string())
s.quit()