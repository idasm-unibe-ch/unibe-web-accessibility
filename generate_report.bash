#!/usr/bin/env bash

OUTPUT_FILE="results/report.json"
JS_FILE="generate_report.js"

# Axe provides the categories: inapplicable, passes, incomplete, violation
# Axes fail condition: violation (non customizable)
# Axes reports: inapplicable, passes, incomplete, violation (non customizable)

# Achecker provides the categories: "violation", "potentialviolation","recommendation","potentialrecommendation",
# "manual","pass","ignored","elements","elementsViolation","elementsViolationReview"
# Achecker fail condition: violation (customizable)
# Achecker reports: violation, potentialviolation, recommendation, potentialrecommendation, manual (customizable)

# HTML_CodeSniffer provide the categories: Notice, Warning, Error
# HTMLCS fail condition: Error (customizable)
# HTMLCS reports: Error, Warning

function axe-results-summary {
    # Define the target directory
    axe_directory="results/axe"

    # Check if the target is not a directory
    if [ ! -d "$axe_directory" ]; then
    echo "Not a directory."
    exit 1
    fi

    # Loop through files in the target directory
    for file in "$axe_directory"/*; do
    if [ -f "$file" ]; then
        # url examined
        url=$(jq '.[0].url' "$file")
        # total errors for url
        # total_errors=$(jq '[.[0].violations[].nodes | length | tonumber ] | add | if . == null then 0 else . end' "$file")
        total_errors=$(jq '.[].violations | length' "$file")
        echo "Axe run on $url found $total_errors error(s)."
        node $JS_FILE "./$file"
    fi
    done    
    
    echo "---------------------------------------------"
}

function achecker-results-summary {
    # Define the target directory
    achecker_directory="results/achecker/localhost_1338"

    # Check if the target is not a directory
    if [ ! -d "$achecker_directory" ]; then
    echo "Not a directory."
    exit 1
    fi

    # Rename home page file
    # Needed for being read in the loop below! 
    mv "$achecker_directory/.json" "$achecker_directory/home.json"

    # Loop through files in the target directory
    for file in "$achecker_directory"/*; do
    if [ -f "$file" ]; then
        url=$(jq '.summary.URL' "$file")
        total_errors=$(jq '.summary.counts.violation' "$file")
        echo "Achecker run on $url found $total_errors error(s)."
        node $JS_FILE "./$file"
    fi
    done

    echo "---------------------------------------------"
}

function htmlcs-results-summary {
    # Define the target directory
    htmlcs_directory="results/HTML_CodeSniffer/"

    # Check if the target is not a directory
    if [ ! -d "$htmlcs_directory" ]; then
    echo "Not a directory."
    exit 1
    fi

    # Loop through files in the target directory
    for file in "$htmlcs_directory"/*; do
    if [ -f "$file" ]; then
        # url examined
        url=$( head -n 1 "$file" )
        # # total numbers of errors
        total_errors=$( grep -wc "Error" "$file")
        echo "HTML_CodeSniffer run on $url found $total_errors error(s)."
        node $JS_FILE "./$file"
    fi
    done

    echo "---------------------------------------------"
}

echo '{"summary": [], "report": []}' > $OUTPUT_FILE
achecker-results-summary
axe-results-summary
htmlcs-results-summary