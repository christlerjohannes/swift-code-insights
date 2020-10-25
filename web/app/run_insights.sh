#!/bin/sh
echo "Hello, ${bamboo.test}!"

bitbucket_token_password=${bamboo.BB_TOKEN}
BBS_URL=${bamboo.BB_BASE_URL}
BBS_PROJECT=${bamboo.BB_PROJECT}
REPORT_KEY=${bamboo.BB_REPORT_SLUG}
BBS_REPO=$1
COMMIT_ID=$2

echo "Cloning Repo"
curl -L \
-H "Authorization: Bearer $bitbucket_token_password" \
"$BBS_URL/rest/api/1.0/projects/$BBS_PROJECT/repos/$BBS_REPO/archive?filename=sourceFiles.zip&at=$COMMIT_ID" \
"-o$COMMIT_ID.zip"
echo "Dome"

echo "Unzipping"
unzip -o -d $COMMIT_ID $COMMIT_ID.zip
echo "Done"

# Run the analysis and parse the output
echo "Running Swift Lint"
touch $COMMIT_ID.out
cd $COMMIT_ID
swiftlint >> ../$COMMIT_ID.out
cd ..
echo "Done"

echo "Parsing SwiftLint output" 
python3 parse.py $COMMIT_ID
echo "Done"

# Create the report or replace the existing one
echo "Creating insight report"
curl \
-H "Content-type: application/json" \
-H "Authorization: Bearer $bitbucket_token_password" \
-X PUT \
-d @report_$COMMIT_ID.json \
"$BBS_URL/rest/insights/latest/projects/$BBS_PROJECT/repos/$BBS_REPO/commits/$COMMIT_ID/reports/$REPORT_KEY"
echo "Done"

# Delete old annotations from the report (they may not exist but it is better to be safe)
echo "Deleting any existing annotations"
curl \
-H "Authorization: Bearer $bitbucket_token_password" \
-H "X-Atlassian-Token: no-check" \
-X DELETE \
"$BBS_URL/rest/insights/latest/projects/$BBS_PROJECT/repos/$BBS_REPO/commits/$COMMIT_ID/reports/$REPORT_KEY/annotations"
echo "Done"

# Create the annotations
echo "Adding annotations to report"
curl \
-H "Content-type: application/json" \
-H "Authorization: Bearer $bitbucket_token_password" \
-X POST \
-d @annotations_$COMMIT_ID.json \
"$BBS_URL/rest/insights/latest/projects/$BBS_PROJECT/repos/$BBS_REPO/commits/$COMMIT_ID/reports/$REPORT_KEY/annotations"
echo "Done"

echo "Cleaning Up"
rm $COMMIT_ID.out
rm $COMMIT_ID.zip
rm annotations_$COMMIT_ID.json
rm report_$COMMIT_ID.json
rm -rf $COMMIT_ID
echo "Done"