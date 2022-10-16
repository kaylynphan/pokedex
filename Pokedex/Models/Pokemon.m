//
//  Pokemon.m
//  Pokedex
//
//  Created by Kaylyn Phan on 10/14/22.
//

#import "Pokemon.h"

@implementation Pokemon

- (id) initWithName:(NSString *)name withImageUrlString:(NSString *)imageUrlString {
    self.name = name;
    NSURL *url = [NSURL URLWithString:imageUrlString];
    self.imageUrl = url;
    return self;
}

@end
