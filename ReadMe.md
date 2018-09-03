# turbojpeg-d

Self-contained D bindings to [libjpeg-turbo](https://libjpeg-turbo.org)-2.0.0.

Dub is configured such as if libjpeg-turbo is found on system (in a compatible version)
the installed version will be used.
Otherwise, libjpeg-turbo-2.0.0 will be downloaded, extracted, built from source and used
in place.
