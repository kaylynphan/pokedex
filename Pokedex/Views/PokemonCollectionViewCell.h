//
//  PokemonCollectionViewCell.h
//  Pokedex
//
//  Created by Kaylyn Phan on 10/14/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PokemonCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pokemonImageView;
@property (weak, nonatomic) IBOutlet UILabel *pokemonNameLabel;

@end

NS_ASSUME_NONNULL_END
