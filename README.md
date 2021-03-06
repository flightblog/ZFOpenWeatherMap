# ZFOpenWeatherMap Xcode Template #

### Detailed Overview ###
ZFOpenWeatherMap is a base template for accessing OpenWeatherMap's API using AFNetworking.

As part of the [Objective-C Hackathon](https://objectivechackathon.appspot.com)

Codebase could change significantly.

### Dependancies ###
AFNetworking

### How To Use ###

```objective-c
    ZFInterface *interface = [[ZFInterface alloc] initWithDelegate:self 
        location:newLocation APIKey:nil];

    interface.cacheInSeconds = 1300;
    [interface retreiveCurrentWeather];
    [interface retreiveForecastWeather];
```

### Contact

Steve Foster [@flightblog](http://twitter.com/flightblog)

### License

The MIT License (MIT)
Copyright © 2013 Steve Foster <foster@flightblog.org>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



