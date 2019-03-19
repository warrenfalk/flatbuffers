#!/bin/bash

CONFIG=Release
SRC=$(dirname $0)

set -ex

echo Building relevant projects.
dotnet restore $SRC/FlatBuffers.sln
dotnet build -c $CONFIG $SRC/FlatBuffers.sln

# TODO: create some tests, then run them
echo "TODO: Create tests"
#echo Running tests.
#dotnet test -c $CONFIG -f netcoreapp1.0 $SRC/FlatBuffers.Test/FlatBuffers.Test.csproj
