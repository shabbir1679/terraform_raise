import datetime
import time
import logging
import requests as reqs
import json
import urllib3
import pprint
import csv
import itertools
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import sonarcleanup as sonar
import nexusdeleteimages as nexusreleases
import deletebranch as branch_delete
# urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# project_key = os.getenv("project_name")
# "ECP.csv" = project_key+".csv"
# print("ECP.csv")


hostname = 'https://testgit.tsys.aws'
repo = []
branch = []
project_key = []
fields = []
cols = []

def delete_sonar():
    with open("ECP.csv") as f:
        csvreader = csv.reader(f)
        next(f)
        for row in csvreader:
            repo = (row[1])
            branch = (row[2])
            # print(fields)
            print("Deleting project key", repo + branch)
            sonar.delete_project(repo, branch)

def delete_nexus_releases():
    with open("ECP.csv") as f:
        csvreader = csv.reader(f)
        next(f)
        for row in csvreader:
            repo = (row[1])
            branch = (row[2])
            print("Deleting branch from following repo: ", branch + repo)
            nexusreleases.get_components_response(repo, branch, 'releases', 'maven2')

def delete_nexus_images():
    with open("ECP.csv") as f:
        csvreader = csv.reader(f)
        next(f)
        for row in csvreader:
            repo = (row[1])
            branch = (row[2])
            print("Deleting image from following repo: ", branch + repo)
            nexusreleases.get_components_response(repo, branch, 'images', 'docker')

def delete_bit_branch(project_key):
    with open("ECP.csv") as f:
        csvreader = csv.reader(f)
        next(f)
        for row in csvreader:
            repo = (row[1])
            branch = (row[2])
            print("Deleting branch from following repo: ", branch + repo)
            branch_delete.del_branch(hostname, project_key, repo, branch) 

# delete_sonar()
# delete_nexus_releases()
# delete_nexus_images()
delete_bit_branch('')



