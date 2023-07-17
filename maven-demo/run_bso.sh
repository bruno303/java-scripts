#!/bin/bash

set -e

## Replaceable vars
EXECUTION_MODULE="web"
MAIN_CLASS="com.bso.mavendemo.Application"
JAVA_OPTS="-Dspring.profiles.active=local -Dspring.output.ansi.enabled=always"
RELOAD_CLASSPATH=0
DEBUG=1


## How to generate classpath for maven modules:
#
# $ mvn dependency:build-classpath -Dmdep.outputFile=.bso/classpath.txt
#

function replace() {
    local newText="$2"
    local text="$3"
    local pattern="$REPLACEMENT_PREFIX/$1.*\\.jar"

    IFS=':' read -ra parts <<< "$text"

    for i in "${!parts[@]}"; do
        # Check if the part contains "oldText" followed by any string and ends with ".jar"
        if [[ ${parts[$i]} =~ $pattern ]]; then
            parts[i]="${parts[$i]//${parts[$i]}/$newText}"
        fi
    done

    local new_text
    new_text=$(IFS=: ; echo "${parts[*]}")
    echo "$new_text"
}

## Internal vars
PROJECT_DIR=$(pwd)
LOCAL_CLASSES="$PROJECT_DIR/$EXECUTION_MODULE/target/classes"
CLASSPATH_FILE="$PROJECT_DIR/$EXECUTION_MODULE/.bso/classpath.txt"

## Classpath work
if [ $RELOAD_CLASSPATH -gt 0 ] || [ ! -f "${CLASSPATH_FILE}" ]; then
    ./mvnw dependency:build-classpath -Dmdep.outputFile=.bso/classpath.txt
fi

CLASSPATH=$(cat "$CLASSPATH_FILE")
# for module in "${SUBMODULES[@]}"; do
#     CLASSPATH=$(replace "$module" "$PROJECT_DIR/$module/target/classes" "$CLASSPATH")
# done

# Include target/classes (resources inside)
CLASSPATH=$(replace "mavendemo/service" "$PROJECT_DIR/service/target/classes" "$CLASSPATH")

FINAL_CLASSPATH="$CLASSPATH:$LOCAL_CLASSES"

## Handle debug flag
if [ $DEBUG -gt 0 ]; then
    JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005"
fi

## Run application
java $JAVA_OPTS \
    -cp "$FINAL_CLASSPATH" \
    "$MAIN_CLASS"
