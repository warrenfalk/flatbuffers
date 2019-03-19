#!/bin/bash
# Builds FlatBuffers NuGet packages

dotnet restore FlatBuffers.sln || exit 1
dotnet pack -c Release FlatBuffers.sln -p:SourceLinkCreate=true || exit 1
