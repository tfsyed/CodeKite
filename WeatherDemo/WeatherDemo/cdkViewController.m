//
//  cdkViewController.m
//  WeatherDemo
//
//  Created by Carlos Hernandez on 2/6/14.
//  Copyright (c) 2014 Carlos Hernandez. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)  // 1

#define kLatestWeatherURL [NSURL URLWithString: @"http://api.openweathermap.org/data/2.5/weather?q=austin,tx&APPID=248e458171fcd11a7b45c08823b982d8"] // 2

#import "cdkViewController.h"

@interface cdkViewController ()

@end

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress;
-(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}
@end

@implementation cdkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: kLatestWeatherURL];
        [self performSelectorOnMainThread:@selector(fetchedData:)withObject:data waitUntilDone:YES];
    });
    
    
}

- (void)fetchedData:(NSData *)responseData{
    // parse out the json data
    NSError* error;
    NSDictionary* austinWeather = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                         options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"responseData: %@", responseData);
    
    //print out the data contents
    _weatherAPI.text = [[NSString alloc] initWithData:responseData
                                             encoding:NSUTF8StringEncoding];
    
    NSLog(@"austin weather: %@", austinWeather);
    
    if (error){
         NSLog(@"%@", [error localizedDescription]);
    }
    else{
        NSDictionary* mainAustin = austinWeather[@"main"];
        NSLog(@"main austin: %@",mainAustin);
        
   
        NSNumber* myhumidity = mainAustin[@"humidity"];
        NSLog(@"humidity: %@", myhumidity);
        
        NSNumber* mypressure = mainAustin[@"pressure"];
        NSLog(@"pressure: %@", mypressure);
        
        NSNumber* mytemp = mainAustin[@"temp"];
        NSLog(@"temp: %@", mytemp);
        
        float mytempcelsius = [mytemp floatValue] - 273.15;
        NSLog(@"temp celsius: %f", mytempcelsius);
        
        float mytempfahrenheit = (mytempcelsius * 1.8) + 32;
        NSLog(@"temp fahrenheit: %f", mytempfahrenheit);
        
        
        _todaysWeather.text = [NSString stringWithFormat: @"Today's temperature is %.2f\u00B0f. \r Humidity is %@%% and \r Pressure at %@ hPa. ", mytempfahrenheit, myhumidity, mypressure];
        

    }
    
   // _todaysWeather.text = [NSString stringWithFormat: @"Today's temperature is %@", mytemp];

    NSDictionary* myInfo =
    [NSDictionary dictionaryWithContentsOfJSONURLString:
     @"http://api.openweathermap.org/data/2.5/weather?q=miami,fl&APPID=248e458171fcd11a7b45c08823b982d8"];
    NSLog(@"myInfo: %@",myInfo);
    
  //  NSDictionary* information =
   // [NSDictionary dictionaryWithObjectsAndKeys:
  //   @"humidity",@"pressure",@"temp",@"temp_max", @"temp_min", nil];
  //  NSData* json = [information toJSON];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
