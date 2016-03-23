Automated Documentation for Fineract API
========================================

This script automatically generates documentation for Apache Fineract API by
walking through the source files. This script is backward compatible with Mifos
X and should work for mifosx instances by just changing the publicPath
parameter in the output JSON.

Usage
-----

From the root directory of your project, run:
```
$ perl iodocs/gen-docs.pl iodocs/docs/public/data/mifosxapi.json [/path/to/new/mifosxapi.json]
```
If the last argument is skipped, this will prompt you whether it should attempt
to overwrite the existing json file.

```
$ perl /path/to/gen-docs.pl [/path/to/fineract-provider] [/path/to/existing/mifosxapi.json] [/path/to/new/mifosxapi.json]
```

The script may need the ```JSON::XS``` CPAN module installed on your system,
which can be installed (on Linux/Mac OSX) by running:

```
$ cpan install JSON::XS
```

Administrator privileges may be required

Credit
------
Thanks to Antony Omeri (github:OmexIT) for sharing his initial JSON document

Copyright
---------
2016, Terence Monteiro
