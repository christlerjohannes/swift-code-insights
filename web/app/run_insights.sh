BB_REPO=$1
COMMIT_ID=$2

echo $BB_TOKEN
echo $BB_BASE_URL
echo $BB_PROJECT
echo $BB_REPORT_SLUG
echo $BB_REPO
echo $COMMIT_ID

echo "Cloning Repo"
curl -L \
-H "Authorization: Bearer $$BB_TOKEN" \
"$BB_BASE_URL/rest/api/1.0/projects/$BB_PROJECT/repos/$BB_REPO/archive?filename=sourceFiles.zip&at=$COMMIT_ID" \
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
-H "Authorization: Bearer $$BB_TOKEN" \
-X PUT \
-d @report_$COMMIT_ID.json \
"$BB_BASE_URL/rest/insights/latest/projects/$BB_PROJECT/repos/$BB_REPO/commits/$COMMIT_ID/reports/$BB_REPORT_SLUG"
echo "Done"

# Delete old annotations from the report (they may not exist but it is better to be safe)
echo "Deleting any existing annotations"
curl \
-H "Authorization: Bearer $$BB_TOKEN" \
-H "X-Atlassian-Token: no-check" \
-X DELETE \
"$BB_BASE_URL/rest/insights/latest/projects/$BB_PROJECT/repos/$BB_REPO/commits/$COMMIT_ID/reports/$BB_REPORT_SLUG/annotations"
echo "Done"

# Create the annotations
echo "Adding annotations to report"
curl \
-H "Content-type: application/json" \
-H "Authorization: Bearer $$BB_TOKEN" \
-X POST \
-d @annotations_$COMMIT_ID.json \
"$BB_BASE_URL/rest/insights/latest/projects/$BB_PROJECT/repos/$BB_REPO/commits/$COMMIT_ID/reports/$BB_REPORT_SLUG/annotations"
echo "Done"

echo "Cleaning Up"
rm $COMMIT_ID.out
rm $COMMIT_ID.zip
rm annotations_$COMMIT_ID.json
rm report_$COMMIT_ID.json
rm -rf $COMMIT_ID
echo "Done"