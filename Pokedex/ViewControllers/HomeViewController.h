//
//  HomeViewController.h
//  Pokedex
//
//  Created by Kaylyn Phan on 10/14/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIImageView *selectedPokemonImageView;
@property (weak, nonatomic) IBOutlet UILabel *selectedPokemonNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pokedexLogo;

@end

NS_ASSUME_NONNULL_END
