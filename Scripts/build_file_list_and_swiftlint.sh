#!/bin/sh

#  build_file_list_and_swiftlint.sh
#  PACTSwift
#
#  Created by Marko Justinek on 26/3/20.
#  Copyright © 2020 PACT Foundation. All rights reserved.

if [ $# -ne 2 ]; then
		echo "usage: build_file_list_and_swiftlint.sh project_name swiftlint_yml"
		exit 1
fi

if which swiftlint >/dev/null; then
		# Build a list of Swift files in the Sources directory
		find Sources -name *.swift -exec echo "\$(SRCROOT)/"{} \; > $DERIVED_FILE_DIR/$1.xcfilelist

		# Update the xcfilelist if the list of Swift files has changed
		cmp --silent $SRCROOT/$1.xcfilelist $DERIVED_FILE_DIR/$1.xcfilelist || cp -f $DERIVED_FILE_DIR/$1.xcfilelist $SRCROOT/$1.xcfilelist

		# Run swiftlint
		swiftlint --path Sources --config $2

		# Output an empty derived file
		touch $DERIVED_FILE_DIR/swiftlint.txt
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
