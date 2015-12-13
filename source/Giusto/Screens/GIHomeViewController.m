//
//  GIHomeViewController.m
//  Giusto
//
//  Created by Nielson Rolim on 6/21/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIHomeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GIQuizQuestionCollectionViewCell.h"
#import "GIQuizQuestion.h"
#import "GIQuizButton.h"
#import "RWTUIImageExtras.h"
#import "GIChangeDietViewController.h"

#define QUIZ_NUMBER_OF_QUESTIONS 5

@interface GIHomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *changeDietView;
@property (weak, nonatomic) IBOutlet UIImageView *editFoodPreferencesView;
@property (weak, nonatomic) IBOutlet UIImageView *findBudsView;
@property (weak, nonatomic) IBOutlet UIImageView *manageTablesView;
@property (weak, nonatomic) IBOutlet UICollectionView *quizCollectionView;

@property (weak, nonatomic) IBOutlet UIView *quizCompleteView;
@property (weak, nonatomic) IBOutlet UIView *noQuizView;

@property (strong, nonatomic) NSMutableArray* quizQuestions;
@property (strong, nonatomic) GIFoodItemType* foodItemTypeIngredients;
@property (strong, nonatomic) NSArray* allIngredients;

@end

@implementation GIHomeViewController

static NSString * const reuseIdentifier = @"QuizCell";

- (NSMutableArray*) quizQuestions {
    if (!_quizQuestions) {
        _quizQuestions = [[NSMutableArray alloc] init];
    }
    return _quizQuestions;
}

- (void)viewDidLoad {
//    NSLog(@"view did load.");

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    PFQuery *query = [PFQuery queryWithClassName:@"UserProfile"];
//    NSArray* pfObjects = [query findObjects];
//    NSMutableArray* userProfiles = [NSMutableArray new];
//    
//    for (PFObject* parseObject in pfObjects) {
//        [userProfiles addObject:[GIUserProfile parseModelWithParseObject:parseObject]];
//    }
//    
//    for (GIUserProfile* up in userProfiles) {
//        NSArray* likedList = [up likedFoodItems];
//        
//        
//        int notDishesCount = 0;
//        int dishesCount = 0;
//
//        for (GIFoodItem* food in likedList) {
//            if (![food.type isEqualToString:@"Dishes"]) {
//                notDishesCount++;
//                [[up.parseObject relationForKey:@"likedFoodItems"] removeObject:food.parseObject];
//            }
//            if ([food.type isEqualToString:@"Dishes"]) {
//                dishesCount++;
//            }
//        }
//
//        [up.parseObject save];
//        
//        NSLog(@"userProfile: %@", up.fullName);
//        NSLog(@"notDishesCount: %lu", (unsigned long)notDishesCount);
//        NSLog(@"dishesCount: %lu", (unsigned long)dishesCount);
//        NSLog(@"---");
//    }
    
    
    
    //Loading Quiz
    [self loadQuiz];
    
}

- (void) viewDidAppear:(BOOL)animated {
    //Configure User Profile Picture - if the user has a profile picture
    [self configureProfilePicture];
}

- (void) loadQuiz {
    [self.view showProgressHUD];
    [self.quizQuestions removeAllObjects];
    if (!self.allIngredients) {

        /*
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
            });
            
        });
         */
        
        [[GIFoodItemTypeStore sharedStore] getFoodItemForName:@"Dishes" withCompletion:^(id sender, BOOL success, NSError *error, NSArray* foodItemType) {

            if (success) {
                self.foodItemTypeIngredients = [foodItemType firstObject];
                
                [[GIFoodItemStore sharedStore] getFoodItemsForQuizForType:self.foodItemTypeIngredients withCompletion:^(id sender, BOOL success, NSError *error, NSArray *result) {
                    if (success) {
                        self.allIngredients = [result copy];
                        [self populateQuiz:self.allIngredients];
                        
                    } else {
                        NSLog(@"Error try to get all ingredients: %@", error.localizedDescription);
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            //Run UI Updates
                            self.noQuizView.hidden = NO;
                            [self.view hideProgressHUD];
                        });

                    }
                }];
                
            } else {
                NSLog(@"Error try to get FoodItemsType Ingredient: %@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
                    self.noQuizView.hidden = NO;
                    [self.view hideProgressHUD];
                });
            }
        }];
    } else {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            [self populateQuiz:self.allIngredients];
        });
    }
    [self slideQuizToBeginning];
}

- (void) populateQuiz:(NSArray*) allIngredients {
    NSUInteger i = 0;
    
//    NSArray* userLikedIngredients = [self.userProfile.likedIngredients copy];
//    NSArray* userDislikedIngredients = [self.userProfile.dislikedIngredients copy];
//    NSArray* userCannotHaveIngredients = [self.userProfile.cannotHaveIngredients copy];
    
    while (i < QUIZ_NUMBER_OF_QUESTIONS) {
        NSUInteger randomIndex = arc4random() % [allIngredients count];

        GIFoodItem* randomFoodItem = allIngredients[randomIndex];
        
        GIQuizQuestion* quizQuestion = [GIQuizQuestion new];
        quizQuestion.foodItem = randomFoodItem;
        quizQuestion.questionNumber = i + 1;
        
        [self.quizQuestions addObject:quizQuestion];
        i++;

        
//        if (![userLikedIngredients containsObject:randomFoodItem]
//            && ![userDislikedIngredients containsObject:randomFoodItem]
//            && ![userCannotHaveIngredients containsObject:randomFoodItem]) {
//            
//            GIQuizQuestion* quizQuestion = [GIQuizQuestion new];
//            quizQuestion.foodItem = randomFoodItem;
//            quizQuestion.questionNumber = i + 1;
//            
//            [self.quizQuestions addObject:quizQuestion];
//            i++;
//        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        //Run UI Updates
        self.quizCollectionView.hidden = NO;
        self.noQuizView.hidden = YES;
        [self.quizCollectionView reloadData];
        [self.view hideProgressHUD];
    });
}

- (void) viewWillAppear:(BOOL)animated {
    [self roundHomeViews];
}

- (void) configureProfilePicture {
    UIView* avatar = [[UIView alloc] initWithFrame:CGRectMake(0,0,32,32)];
    
    UIImageView* avatarPicture =[[UIImageView alloc] initWithFrame:CGRectMake(2,2,28,28)];
    
    if (self.userProfile.photoURL) {
        [avatarPicture setImageWithURL:self.userProfile.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    } else {
        avatarPicture.image = [UIImage imageNamed:@"AvatarImagePlaceholder"];
    }

    UIImageView* avatarFrame =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,32,32)];
    avatarFrame.image=[UIImage imageNamed:@"AvatarImageFrame"];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 32, 32);
    [btn addTarget:self action:@selector(showSettingsModal) forControlEvents:UIControlEventTouchUpInside];
    
    [avatar addSubview:avatarPicture];
    [avatar addSubview:avatarFrame];
    [avatar addSubview:btn];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:avatar];
    self.navigationItem.leftBarButtonItem = item;
}

- (void) showSettingsModal {
//    NSLog(@"showSettingsModal");
    [self performSegueWithIdentifier:@"modalSettingsFromHome" sender:self];
}

- (void) roundHomeViews {
    CGColorRef borderColor = [UIColor lightGrayColor].CGColor;
    float borderSize = 0.5f;
    
    self.changeDietView.layer.borderColor = borderColor;
    self.changeDietView.layer.borderWidth = borderSize;
    self.editFoodPreferencesView.layer.borderColor = borderColor;
    self.editFoodPreferencesView.layer.borderWidth = borderSize;
    self.findBudsView.layer.borderColor = borderColor;
    self.findBudsView.layer.borderWidth = borderSize;
    self.manageTablesView.layer.borderColor = borderColor;
    self.manageTablesView.layer.borderWidth = borderSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"changeDietSegue"]) {
        GIChangeDietViewController* changeDietVC = segue.destinationViewController;
        [changeDietVC configureWithModelObject:[GIUserStore sharedStore].currentUser.userProfile];
    }
}
 

- (IBAction)ChangeDietButtonPressed:(UIButton *)sender {
}

- (IBAction)editFoodPreferencesButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedIndex = 1;
}

- (IBAction)findBudsButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedIndex = 2;
}

- (IBAction)manageTablesButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedIndex = 3;
}

- (void) slideQuiz:(GIQuizButton*) sender {
    if (sender.quizQuestion.questionNumber == self.quizQuestions.count) {
        self.quizCollectionView.hidden = YES;
        self.quizCompleteView.hidden = NO;
        [self.view hideProgressHUD];
    } else {
        NSArray *visibleItems = [self.quizCollectionView indexPathsForVisibleItems];
        NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:currentItem.item + 1 inSection:currentItem.section];
        if (nextItem.row < self.quizQuestions.count) {
            [self.quizCollectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    }
}

- (void) slideQuizToBeginning {
    [self.quizCollectionView setContentOffset:CGPointZero animated:NO];
}

- (IBAction)likeButtonPressed:(GIQuizButton*)sender {
    
    //    GIFoodItemCategoryLikes
    //    GIFoodItemCategoryDislikes
    //    GIFoodItemCategoryCannotHaves
    
    [self.view showProgressHUD];
    
    [[GIFoodItemStore sharedStore] removeFoodItem:sender.quizQuestion.foodItem FromProfile:self.userProfile category:GIFoodItemCategoryCannotHaves completion:^(id sender, BOOL success, NSError *error, id result) {
        
    }];
    
    [[GIFoodItemStore sharedStore] removeFoodItem:sender.quizQuestion.foodItem FromProfile:self.userProfile category:GIFoodItemCategoryDislikes completion:^(id sender, BOOL success, NSError *error, id result) {
        
    }];
    
    [[GIFoodItemStore sharedStore] addFoodItem:sender.quizQuestion.foodItem toProfile:self.userProfile itemCategory:GIFoodItemCategoryLikes completion:^(id sender, BOOL success, NSError *error, id result) {
    }];
    
    [self slideQuiz:sender];
}

- (IBAction)dislikeButtonPressed:(GIQuizButton *)sender {
    //    GIFoodItemCategoryLikes
    //    GIFoodItemCategoryDislikes
    //    GIFoodItemCategoryCannotHaves
    
    [self.view showProgressHUD];
    
    [[GIFoodItemStore sharedStore] removeFoodItem:sender.quizQuestion.foodItem FromProfile:self.userProfile category:GIFoodItemCategoryCannotHaves completion:^(id sender, BOOL success, NSError *error, id result) {
        
    }];
    
    [[GIFoodItemStore sharedStore] removeFoodItem:sender.quizQuestion.foodItem FromProfile:self.userProfile category:GIFoodItemCategoryLikes completion:^(id sender, BOOL success, NSError *error, id result) {
        
    }];
    
    [[GIFoodItemStore sharedStore] addFoodItem:sender.quizQuestion.foodItem toProfile:self.userProfile itemCategory:GIFoodItemCategoryDislikes completion:^(id sender, BOOL success, NSError *error, id result) {
    }];
    
    [self slideQuiz:sender];
}

- (IBAction)cannotHaveButtonPressed:(GIQuizButton *)sender {
    //    GIFoodItemCategoryLikes
    //    GIFoodItemCategoryDislikes
    //    GIFoodItemCategoryCannotHaves
    
    [self.view showProgressHUD];

    [[GIFoodItemStore sharedStore] removeFoodItem:sender.quizQuestion.foodItem FromProfile:self.userProfile category:GIFoodItemCategoryLikes completion:^(id sender, BOOL success, NSError *error, id result) {
        
    }];
    
    [[GIFoodItemStore sharedStore] removeFoodItem:sender.quizQuestion.foodItem FromProfile:self.userProfile category:GIFoodItemCategoryDislikes completion:^(id sender, BOOL success, NSError *error, id result) {
        
    }];
    
    [[GIFoodItemStore sharedStore] addFoodItem:sender.quizQuestion.foodItem toProfile:self.userProfile itemCategory:GIFoodItemCategoryCannotHaves completion:^(id sender, BOOL success, NSError *error, id result) {
    }];
    
    [self slideQuiz:sender];
}

- (IBAction)takeAnotherQuizButtonPressed:(UIButton *)sender {
    [self.view showProgressHUD];
    // Get a concurrent queue form the system
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(concurrentQueue, ^{
        [self loadQuiz];
    });
}

- (IBAction)notTakeAnotherQuizButtonPressed:(UIButton *)sender {
    self.quizCompleteView.hidden = YES;
    self.noQuizView.hidden = NO;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.quizQuestions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GIQuizQuestionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    GIQuizQuestion* quizQuestion = self.quizQuestions[indexPath.row];
    cell.questionLabel.text = [NSString stringWithFormat:@"How do you feel about %@?", quizQuestion.foodItem.name];
    cell.questionNumberLabel.text = [NSString stringWithFormat:@"QUESTION %lu OF %lu", (unsigned long)quizQuestion.questionNumber, (unsigned long)self.quizQuestions.count];
    cell.likeButton.quizQuestion = quizQuestion;
    cell.dislikeButton.quizQuestion = quizQuestion;
    cell.cannotHaveButton.quizQuestion = quizQuestion;
    
    
    NSString* photoURL = [NSString stringWithFormat:@"http://%@", quizQuestion.foodItem.photoURL];
//    NSLog(@"photoURL: %@", photoURL);
    UIImage* fullImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
    
    // 1) Show loading view
    [self.view showProgressHUD];
    
    // 2) Get a concurrent queue form the system
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 3) Resize image in background
    dispatch_async(concurrentQueue, ^{
        
        UIImage *resizedImage = [fullImage imageByScalingAndCroppingForSize:CGSizeMake(320, 178)];
        
        // 4) Present image in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundImage.image = resizedImage;
            [self.view hideProgressHUD];
        });
        
    });
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(self.quizCollectionView.frame.size.width, self.quizCollectionView.frame.size.height);
}

@end
