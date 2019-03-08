//
//  WHQuestionnaireViewController.m
//  WHXMLDemo
//
//  Created by zero on 2019/3/8.
//  Copyright © 2019 zero. All rights reserved.
//

#import "WHQuestionnaireViewController.h"

#import <Ono/Ono.h>

#import <DLRadioButton/DLRadioButton.h>

#import <RadioButton/RadioButton.h>

#import "WHRadioButton.h"

#import <YYCategories/YYCategories.h>

@interface WHQuestionnaireViewController ()<MHRadioButtonDelegate>

@property (nonatomic, strong) ONOXMLDocument* document;

@property (nonatomic, copy) NSArray<ONOXMLElement *>* children;

@end

@implementation WHQuestionnaireViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self loadXmlFile];
//        [self initializeForm];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self loadXmlFile];
//        [self initializeForm];
        
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

- (void)loadXmlFile
{
    NSString* xmlFilePath = [[NSBundle mainBundle] pathForResource:@"q" ofType:@"xml"];
    
    NSData* data = [NSData dataWithContentsOfFile:xmlFilePath];
    
    NSError* error;
    
    _document = [ONOXMLDocument XMLDocumentWithData:data error:&error];
    
    _children = _document.rootElement.children;
    
    if (error || nil == _document) {
        NSLog(@"[Error] %@", error);
    }
    
    [_document.rootElement.children enumerateObjectsUsingBlock:^(ONOXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        NSLog(@"%@", obj.attributes);
    }];
    
}


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
        btnRect.origin.y += 20;
        
        if  (![obj[@"extAnswer"] isKindOfClass:[NSString class]]) {
            ;
            UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(btnRect.size.width * .5, btnRect.origin.y + 2.5, btnRect.size.width * .5, 25)];
            tf.font = [UIFont boldSystemFontOfSize:font.integerValue * .5];
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
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:font.integerValue * .5];
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
        
        btnRect.origin.y += 20;
        
        if  (![obj[@"extAnswer"] isKindOfClass:[NSString class]]) {
            UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(btnRect.size.width / 2, btnRect.origin.y + 2.5, btnRect.size.width / 2, 25)];
            
            tf.font = [UIFont boldSystemFontOfSize:font.integerValue * .5];
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
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:font.integerValue * .5];
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
    nameTF.font = [UIFont boldSystemFontOfSize:font.integerValue * .5];
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

//- (void)initializeForm
//{
//    XLFormDescriptor * form; //form，一个表单只有一个
//    XLFormSectionDescriptor * section; //section，一个表单可能有多个
//    XLFormRowDescriptor * row; //row，每个section可能有多个row
//
//    // Form
//    form = [XLFormDescriptor formDescriptor];
//
//
//    for (<#type *object#> in <#collection#>) {
//        <#statements#>
//    }
//
//
//    // First section
//    section = [XLFormSectionDescriptor formSection];
//    section.title = @"用户";
//    [form addFormSection:section];
//    // 普通文本
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"username" rowType:XLFormRowDescriptorTypeText];
//    // 设置placeholder
//    [row.cellConfig setObject:@"用户名" forKey:@"textField.placeholder"];
//    // 设置文本颜色
//    [row.cellConfig setObject:[UIColor redColor] forKey:@"textField.textColor"];
//    [section addFormRow:row];
//    // 密码
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"password" rowType:XLFormRowDescriptorTypePassword];
//    // 设置placeholder的颜色
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"密码" attributes:
//                                      @{NSForegroundColorAttributeName:[UIColor greenColor],
//                                        }];
//    [row.cellConfig setObject:attrString forKey:@"textField.attributedPlaceholder"];
//    [section addFormRow:row];
//
//
//
//    // Second Section
//    section = [XLFormSectionDescriptor formSection];
//    section.title = @"日期";
//    [form addFormSection:section];
//    // 日期选择器
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"birthday" rowType:XLFormRowDescriptorTypeDate title:@"出生日期"];
//    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
//    [section addFormRow:row];
//
//
//
//    // Third Section
//    section = [XLFormSectionDescriptor formSection];
//    section.title = @"头像";
//    [form addFormSection:section];
//    // 图片选择
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userpic" rowType:XLFormRowDescriptorTypeImage];
//    [section addFormRow:row];
//
//
//
//    // Fourth Section
//    section = [XLFormSectionDescriptor formSection];
//    section.title = @"选择器";
//    [form addFormSection:section];
//    // 选择器
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"sex" rowType:XLFormRowDescriptorTypeSelectorPush];
//    row.noValueDisplayText = @"暂无";
//    row.selectorTitle = @"性别选择";
//    row.selectorOptions = @[@"男",@"女",@"其他"];
//    row.title = @"性别";
//    [row.cellConfigForSelector setObject:[UIColor redColor] forKey:@"textLabel.textColor"];
//    [row.cellConfigForSelector setObject:[UIColor greenColor] forKey:@"detailTextLabel.textColor"];
//    [section addFormRow:row];
//
//
//
//    // Fifth Section
//    section = [XLFormSectionDescriptor formSection];
//    section.title = @"加固";
//    [form addFormSection:section];
//    // 开关
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"enforce" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"加固"];
//    [section addFormRow:row];
//
//
//    // Sixth Section
//    section = [XLFormSectionDescriptor formSection];
//    [form addFormSection:section];
//    // 按钮
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"conform" rowType:XLFormRowDescriptorTypeButton];
//    row.title = @"提交";
//    [section addFormRow:row];
//
//
//    self.form = form;
//}


#pragma mark - public methods



#pragma mark - Event Response methods




#pragma mark - Custom Delegate


- (void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId
{
    
}


#pragma mark - getter



#pragma mark - setter



@end
