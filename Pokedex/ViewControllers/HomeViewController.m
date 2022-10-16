//
//  HomeViewController.m
//  Pokedex
//
//  Created by Kaylyn Phan on 10/14/22.
//

#import "HomeViewController.h"
#import "PokemonCollectionViewCell.h"
#import "Pokemon.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "InfiniteScrollActivityView.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSMutableArray *pokemonArray;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) NSInteger offset;
@property (weak, nonatomic) InfiniteScrollActivityView* loadingMoreView;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.isMoreDataLoading = false;
    self.offset = 0;
    CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.collectionView addSubview:self.loadingMoreView];
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.collectionView.contentInset = insets;
    
    self.pokemonArray = [[NSMutableArray alloc] init];
    
    self.isMoreDataLoading = true;
    [self fetchPokemonWithOffset:self.offset withCompletion:^(NSArray *pokemonUrlArray, NSError *error) {
        for (NSString *urlString in pokemonUrlArray) {
            [self fetchPokemonDetailsAtURL:[NSURL URLWithString:urlString]];
        }
        self.isMoreDataLoading = false;
    }];
}

- (void)viewDidLayoutSubviews {
   [super viewDidLayoutSubviews];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)fetchPokemonWithOffset:(NSInteger)offset withCompletion:(void(^)(NSArray *pokemonUrlArray, NSError *error))completion {
    NSString *urlStringWithOffset = [@"https://pokeapi.co/api/v2/pokemon?limit=20&offset=" stringByAppendingString:[@(offset) stringValue]];
    NSURL *url = [NSURL URLWithString:urlStringWithOffset];
    
    // obtain the number of pokemon
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *resultArray = dataDictionary[@"results"];
            NSLog(@"%@", resultArray);
            NSMutableArray *pokemonUrlArray = [[NSMutableArray alloc] init];
            for (NSDictionary *item in resultArray) {
                [pokemonUrlArray addObject:item[@"url"]];
            }
            completion(pokemonUrlArray, nil);
        }
    }];
    [task resume];
}

- (void)fetchPokemonDetailsAtURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", dataDictionary);
            NSString *imageUrlString = dataDictionary[@"sprites"][@"front_default"];
            NSString *name = dataDictionary[@"name"];
            [self.pokemonArray addObject:[[Pokemon alloc] initWithName:name withImageUrlString:imageUrlString]];
            [self.collectionView reloadData];
        }
    }];
    [task resume];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pokemonArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PokemonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"pokemonCollectionViewCell" forIndexPath:indexPath];
    Pokemon *thisPokemon = self.pokemonArray[indexPath.item];
    [cell.pokemonImageView setImageWithURL:thisPokemon.imageUrl];
    cell.pokemonNameLabel.text = thisPokemon.name;
    [cell.pokemonNameLabel sizeToFit];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    int totalwidth = self.collectionView.bounds.size.width;
    int numberOfCellsPerRow = 3;
    int cellWidth = (CGFloat)(totalwidth / numberOfCellsPerRow);
    return CGSizeMake(cellWidth, cellWidth * 1.2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Pokemon *selectedPokemon = self.pokemonArray[indexPath.item];
    [self.selectedPokemonImageView setImageWithURL:selectedPokemon.imageUrl];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.collectionView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.collectionView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.collectionView.isDragging) {
            self.isMoreDataLoading = true;
            CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            self.loadingMoreView.frame = frame;
            [self.loadingMoreView startAnimating];
            
            // Load more pokemon
            self.offset += 20;
            [self fetchPokemonWithOffset:self.offset withCompletion:^(NSArray *pokemonUrlArray, NSError *error) {
                for (NSString *urlString in pokemonUrlArray) {
                    [self fetchPokemonDetailsAtURL:[NSURL URLWithString:urlString]];
                }
                self.isMoreDataLoading = false;
            }];
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
