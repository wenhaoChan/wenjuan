//
//  WHQuestionnaireViewController.m
//  WHXMLDemo
//
//  Created by zero on 2019/3/8.
//  Copyright © 2019 zero. All rights reserved.
//

#import "WHQuestionnaireViewController.h"

#import <Ono/Ono.h>

#import <RadioButton/RadioButton.h>

#import <YYCategories/YYCategories.h>

@interface WHQuestionnaireViewController ()

@property (nonatomic, strong) ONOXMLDocument* document;

@property (nonatomic, copy) NSArray<ONOXMLElement *>* children;

@end

@implementation WHQuestionnaireViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self loadXmlFile];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self loadXmlFile];
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self setupSubviews];
    // Do any additional setup after loading the view.
}

#pragma mark - life cycles methods


#pragma mark - private methods

#pragma mark 加载本地 xml 文件

- (void)loadXmlFile
{
    NSString* xmlFilePath = [[NSBundle mainBundle] pathForResource:@"q" ofType:@"xml"];
    
    NSData* data = [NSData dataWithContentsOfFile:xmlFilePath];
    
    NSError* error;
    
    // 解析 xml 获取节点对象
    
    _document = [ONOXMLDocument XMLDocumentWithData:data error:&error];
    
    _children = _document.rootElement.children;
    
    if (error || nil == _document) {
        NSLog(@"[Error] %@", error);
    }
    
//    [_document.rootElement.children enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
//        NSLog(@"%@", obj.attributes);
//    }];
    
}


/**
 第一种方案
 1. 通过分析节点结构 提前定义好 如：radio单选按钮 checkbox多选框 输入框 等控件
 2. 获取每个节点 分拆属性 创建对应的UI控件
 3. 加到视图中去
 
 第二种 （未实现）
 根据节点 构建表单（非web表单，是OS风格）
 可以结合 XLForm 这个s第三方
 */
- (void)setupSubviews
{
    
    ONOXMLElement* e = [_document firstChildWithXPath:@"//radioList/options"];

    NSString* textColor = [[_document firstChildWithXPath:@"//radioList/color"] stringValue];

    NSNumber* font = [[_document firstChildWithXPath:@"//radioList/fontSize"] numberValue];

    NSArray<ONOXMLElement *>* options = [e childrenWithTag:@"option"];

    NSMutableArray<NSMutableDictionary*>* radios = [NSMutableArray array];
    [options enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [obj.children enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {

            if (obj1.children.count > 0) {
                NSMutableDictionary* d = [NSMutableDictionary dictionary];
                [obj1.children enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
                    d[obj2.tag] = obj2.stringValue;
                }];
                dic[obj1.tag] = d;
            } else {
                dic[obj1.tag] = obj1.stringValue;
            }
        }];
        [radios addObject:dic];
    }];


    NSMutableArray* buttonsArray = [NSMutableArray arrayWithCapacity:radios.count];
    __block CGRect btnRect = CGRectMake(0, 44, self.view.frame.size.width, 30);

    [radios enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        RadioButton* btn = [[RadioButton alloc] initWithFrame:btnRect];
        btnRect.origin.y += 30;
        
        if  (![obj[@"extAnswer"] isKindOfClass:[NSString class]]) {
            ;
            UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(btnRect.size.width * .5, btnRect.origin.y + 2.5, btnRect.size.width * .5, 25)];
            tf.font = [UIFont boldSystemFontOfSize:font.integerValue];
            tf.textColor = [UIColor colorWithHexString:textColor];
            tf.placeholder = obj[@"extAnswer"][@"placeholder"];
            [self.view addSubview:tf];
            btn.frame = CGRectMake(btnRect.origin.x, btnRect.origin.y, btnRect.size.width / 2, btnRect.size.height);
        } else {
            btn.frame = CGRectMake(btnRect.origin.x, btnRect.origin.y, btnRect.size.width, btnRect.size.height);
        }
        
        NSString* title = [NSString stringWithFormat:@"%@ %@ %@ %@", obj[@"num"], obj[@"txt"], obj[@"img"], obj[@"desc"]];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:textColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:font.integerValue];
        [btn setImage:[UIImage imageNamed:@"normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [btn setSelected:[obj[@"isChecked"] boolValue]];
        [self.view addSubview:btn];
        [buttonsArray addObject:btn];
    }];

    [buttonsArray[0] setGroupButtons:buttonsArray]; // 把按钮放进群组中
    
    
    
    e = [_document firstChildWithXPath:@"//checkboxList/options"];
    
    textColor = [[_document firstChildWithXPath:@"//checkboxList/color"] stringValue];
    
    font = [[_document firstChildWithXPath:@"//checkboxList/fontSize"] numberValue];
    
    options = [e childrenWithTag:@"option"];
    
    NSMutableArray<NSMutableDictionary*>* boxes = [NSMutableArray array];
    [options enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [obj.children enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
            
            if (obj1.children.count > 0) {
                NSMutableDictionary* d = [NSMutableDictionary dictionary];
                [obj1.children enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
                    d[obj2.tag] = obj2.stringValue;
                }];
                dic[obj1.tag] = d;
            } else {
                dic[obj1.tag] = obj1.stringValue;
            }
        }];
        [boxes addObject:dic];
    }];
    
    
    NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:boxes.count];
    btnRect = CGRectMake(0, btnRect.origin.y + btnRect.size.height, self.view.width, 30);
    
    [boxes enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton* btn = [[UIButton alloc] init];
        
        btnRect.origin.y += 30;
        
        if  (![obj[@"extAnswer"] isKindOfClass:[NSString class]]) {
            UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(btnRect.size.width / 2, btnRect.origin.y + 2.5, btnRect.size.width / 2, 25)];
            
            tf.font = [UIFont boldSystemFontOfSize:font.integerValue];
            tf.textColor = [UIColor colorWithHexString:textColor];
            tf.placeholder = obj[@"extAnswer"][@"placeholder"];
            [self.view addSubview:tf];
            btn.frame = CGRectMake(btnRect.origin.x, btnRect.origin.y, btnRect.size.width / 2, btnRect.size.height);
        } else {
            btn.frame = CGRectMake(btnRect.origin.x, btnRect.origin.y, btnRect.size.width, btnRect.size.height);
        }
        
        NSString* title = [NSString stringWithFormat:@"%@ %@ %@ %@", obj[@"num"], obj[@"txt"], obj[@"img"], obj[@"desc"]];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:textColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:font.integerValue];
        [btn setImage:[UIImage imageNamed:@"normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [btn setSelected:[obj[@"isChecked"] boolValue]];
        [btn addTarget:self action:@selector(checkBoxChangeStatus:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:btn];
        [buttons addObject:btn];
    }];
    
    NSMutableDictionary* nameDic = [NSMutableDictionary dictionary];
    ONOXMLElement* input = [_document firstChildWithXPath:@"//input"];
    [input.children enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        nameDic[obj.tag] = obj.stringValue;
    }];
    
    btnRect.origin.y += 40;
    UITextField* nameTF = [[UITextField alloc] initWithFrame:CGRectMake(30, btnRect.origin.y, btnRect.size.width - 60, 20)];
    nameTF.placeholder = nameDic[@"placeholder"];
    nameTF.font = [UIFont boldSystemFontOfSize:font.integerValue];
    nameTF.textColor = [UIColor colorWithHexString:textColor];
    [self.view addSubview:nameTF];
    
    btnRect.origin.y += 100;
    UILabel* tipsLable = [[UILabel alloc] initWithFrame:btnRect];
    tipsLable.textColor = [UIColor redColor];
    tipsLable.text = @"* 注  后面的实现方法都一样 暂省略。。。";
    tipsLable.textAlignment = NSTextAlignmentCenter;
    tipsLable.font = [UIFont systemFontOfSize:20.f];
    [self.view addSubview:tipsLable];
}


- (void)checkBoxChangeStatus:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
}



#pragma mark - public methods


#pragma mark - Event Response methods


#pragma mark - Custom Delegate


#pragma mark - getter


#pragma mark - setter



@end
