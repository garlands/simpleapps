//
//  AlbumCollectionViewController.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "AlbumCollectionViewCell.h"
#import "Track+Provider.h"
#import "Album+Provider.h"
#import "AlbumViewController.h"

#import "AudioManager.h"
#import "AppDelegate.h"

//
@interface AlbumCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    AudioManager *avmgr;
    BOOL portrait;
    NSNumber *_album_kind;
    NSArray *_tracks;
    NSArray *_albums;
}
@end

@implementation AlbumCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    avmgr = [AudioManager sharedInstance];
    self.view.backgroundColor = UIColor.blackColor;
    _albums = [Album musicLibraryAlbums];
}

-(void) enterBackground
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) receiveMemoryWarning:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGSize listCellSize = CGSizeMake(screenSize.size.width, screenSize.size.width);
    return listCellSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    [self.collectionViewLayout invalidateLayout];
//    [self.collectionView reloadData];
}


#pragma mark - segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//}

#pragma mark - collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [_albums count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell"
                                                                forIndexPath:indexPath];
    Album *album = [_albums objectAtIndex:(int)indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    NSLog(@" %d %@", (int)indexPath.row, album.album);
    
    MPMediaItemArtwork *artwork = album.artwork;
    UIImage *artworkImage = [artwork imageWithSize:CGSizeMake(80.0, 80.0)];
    if( artworkImage != NULL )
        imageView.image = artworkImage;
    else
    {
        UIImage *image = [UIImage imageNamed:@"logo.png"];
        imageView.image = image;
    }
    
    UILabel *title_label = (UILabel *)[cell viewWithTag:2];
    if( album.album != NULL )
        title_label.text = album.album;
    else
        title_label.text = @"";
    
    UILabel *artist_label = (UILabel *)[cell viewWithTag:4];
    if( album.artist != NULL )
        artist_label.text = album.artist;
    else
        artist_label.text = @"";

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select cell %d", (int)indexPath.row);
    Album *album = [_albums objectAtIndex:(int)indexPath.row];
    if( album.album != NULL )
    {
        [avmgr setAlbum_index_Temp:indexPath.row];
        [avmgr setAlbumsTemp:_albums];
        [avmgr setCurrentAlbumTitle:YES albumtitle:album.album];
        [avmgr setTracksTemp:[Track musicLibraryTracks_album:album.album]];
        [avmgr setupAlbum:NO download:NO];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AlbumDetail" bundle:nil];
        AlbumViewController *next = (AlbumViewController *)[storyboard instantiateInitialViewController];
        [next setAlbum_kind:[_album_kind intValue]];
//        [self.navigationController pushViewController:next animated:YES];
        [self presentViewController:next animated:YES completion:nil];
    }
}
@end
