import json, os, sys

commit = sys.argv[1]
file = open(commit + '.out', 'r') 
lines = file.readlines() 

annotations = []
warning_count = 0
error_count = 0

# Strips the newline character 
for line in lines: 
    if 'warning' in line:
        warning_count += 1
        path_and_line = line.split('warning: ')[0]
        message = line.split('warning: ')[1]
        
        path = path_and_line.split(':')[0].replace(os.getcwd() + '/' + commit + "/", '')
        line = path_and_line.split(':')[1].split(':')[0]
        
        annotations.append({
            'path': path,
            'line': line,
            'message': message,
            'severity': 'MEDIUM'
        })
        
    if 'error' in line:
        error_count += 1
        path_and_line = line.split('error: ')[0]
        message = line.split('error: ')[1]
        
        path = path_and_line.split(':')[0].replace(os.getcwd() + '/' + commit + "/", '')
        line = path_and_line.split(':')[1].split(':')[0]
        
        annotations.append({
            'path': path,
            'line': line,
            'message': message,
            'severity': 'HIGH'
        })
        
with open('report_' + commit + '.json', 'w') as report_file:
    report = {
        'title': 'SwiftLint report',
        'vendor': 'Swiftlint',
        'logoUrl': 'https://avatars3.githubusercontent.com/u/7575099?s=400&v=4',
        'data': [
            {
                'title': 'Error Count',
                'value': error_count           
            },
            {
                'title': 'Warning Count',
                'value': warning_count
            }
        ]
    }
    
    # Write the report json to file
    json.dump(report, report_file)
        
with open('annotations_' + commit + '.json', 'w') as annotation_file:
    # Write the annotations json to file
    json.dump({'annotations': annotations}, annotation_file)
