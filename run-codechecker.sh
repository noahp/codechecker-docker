#!/usr/bin/env bash

set -e

CodeChecker log -b "$@" -o compile_commands.json
CodeChecker analyze compile_commands.json -o ./reports --enable sensitive --ctu
CodeChecker parse ./reports -e html -o ./reports_html
