Automated Documentation for Fineract API
========================================

This script automatically generates documentation for Apache Fineract API by
walking through the source files. This script is backward compatible with Mifos
X and should work for mifosx instances by just changing the publicPath
parameter in the output JSON.

Usage
-----

```
  perl /path/to/gen-docs.pl [/path/to/fineract-provider] [/path/to/existing/mifosxapi.json] [/path/to/new/mifosxapi.json]
```

The script may need the ```JSON::XS``` CPAN module installed on your system,
which can be installed (on Linux/Mac OSX) by running:

```
cpan install JSON::XS
```

Administrator privileges may be required
