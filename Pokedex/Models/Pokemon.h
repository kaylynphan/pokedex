//
//  Pokemon.h
//  Pokedex
//
//  Created by Kaylyn Phan on 10/14/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Pokemon : NSObject

@property (weak, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *imageUrl;

- (id) initWithName:(NSString *)name withImageUrlString:(NSString *)imageUrlString;

@end

NS_ASSUME_NONNULL_END
