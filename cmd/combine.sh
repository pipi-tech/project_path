#!/bin/bash
LOG=~/project/project_path/data/log/terminal/output/session.log
INPUT=~/project/project_path/data/log/terminal/input

echo "---" >> $LOG
cat $INPUT/when.txt >> $LOG
cat $INPUT/who.txt >> $LOG
cat $INPUT/terminal.txt >> $LOG
echo "project: $(cat $INPUT/project.txt)" >> $LOG
