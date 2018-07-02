//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "OWSContactShareView.h"
#import "OWSContactAvatarBuilder.h"
#import "Signal-Swift.h"
#import "UIColor+OWS.h"
#import "UIFont+OWS.h"
#import "UIView+OWS.h"
#import <SignalMessaging/Environment.h>
#import <SignalMessaging/SignalMessaging-Swift.h>
#import <SignalMessaging/UIColor+OWS.h>
#import <SignalServiceKit/OWSContact.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSContactShareView ()

@property (nonatomic, readonly) ContactShareViewModel *contactShare;

@property (nonatomic, readonly) BOOL isIncoming;
@property (nonatomic, readonly) OWSContactsManager *contactsManager;

@end

#pragma mark -

@implementation OWSContactShareView

- (instancetype)initWithContactShare:(ContactShareViewModel *)contactShare
                          isIncoming:(BOOL)isIncoming
{
    self = [super init];

    if (self) {
        _contactShare = contactShare;
        _isIncoming = isIncoming;
        _contactsManager = [Environment current].contactsManager;
    }

    return self;
}

#pragma mark -

- (CGFloat)hMargin
{
    return 12.f;
}

+ (CGFloat)vMargin
{
    return 0.f;
}

- (CGFloat)iconHSpacing
{
    return 8.f;
}

+ (CGFloat)bubbleHeight
{
    return self.contentHeight;
}

+ (CGFloat)contentHeight
{
    CGFloat labelsHeight = (self.nameFont.lineHeight + self.labelsVSpacing + self.subtitleFont.lineHeight);
    CGFloat contentHeight = MAX(self.iconSize, labelsHeight);
    contentHeight += OWSContactShareView.vMargin * 2;
    return contentHeight;
}

+ (CGFloat)iconSize
{
    return 48.f;
}

- (CGFloat)iconSize
{
    return [OWSContactShareView iconSize];
}

+ (UIFont *)nameFont
{
    return [UIFont ows_dynamicTypeBodyFont];
}

+ (UIFont *)subtitleFont
{
    return [UIFont ows_dynamicTypeCaption1Font];
}

+ (CGFloat)labelsVSpacing
{
    return 2;
}

- (void)createContents
{
    self.layoutMargins = UIEdgeInsetsZero;

    UIColor *textColor = (self.isIncoming ? [UIColor ows_whiteColor] : [UIColor ows_light90Color]);

    AvatarImageView *avatarView = [AvatarImageView new];
    avatarView.image =
        [self.contactShare getAvatarImageWithDiameter:self.iconSize contactsManager:self.contactsManager];

    [avatarView autoSetDimension:ALDimensionWidth toSize:self.iconSize];
    [avatarView autoSetDimension:ALDimensionHeight toSize:self.iconSize];
    [avatarView setCompressionResistanceHigh];
    [avatarView setContentHuggingHigh];

    UILabel *topLabel = [UILabel new];
    topLabel.text = self.contactShare.displayName;
    topLabel.textColor = textColor;
    topLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    topLabel.font = OWSContactShareView.nameFont;

    UIStackView *labelsView = [UIStackView new];
    labelsView.axis = UILayoutConstraintAxisVertical;
    labelsView.spacing = OWSContactShareView.labelsVSpacing;
    [labelsView addArrangedSubview:topLabel];

    NSString *_Nullable firstPhoneNumber =
        [self.contactShare systemContactsWithSignalAccountPhoneNumbers:self.contactsManager].firstObject;
    if (firstPhoneNumber.length > 0) {
        UILabel *bottomLabel = [UILabel new];
        bottomLabel.text = [PhoneNumber bestEffortLocalizedPhoneNumberWithE164:firstPhoneNumber];
        // TODO:
        bottomLabel.textColor = [textColor colorWithAlphaComponent:0.7f];
        bottomLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        bottomLabel.font = OWSContactShareView.subtitleFont;
        [labelsView addArrangedSubview:bottomLabel];
    }

    UIImage *disclosureImage =
        [UIImage imageNamed:(CurrentAppContext().isRTL ? @"small_chevron_left" : @"small_chevron_right")];
    OWSAssert(disclosureImage);
    UIImageView *disclosureImageView = [UIImageView new];
    disclosureImageView.image = [disclosureImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    disclosureImageView.tintColor = textColor;
    [disclosureImageView setCompressionResistanceHigh];
    [disclosureImageView setContentHuggingHigh];

    UIStackView *hStackView = [UIStackView new];
    hStackView.axis = UILayoutConstraintAxisHorizontal;
    hStackView.spacing = self.iconHSpacing;
    hStackView.alignment = UIStackViewAlignmentCenter;
    hStackView.layoutMarginsRelativeArrangement = YES;
    hStackView.layoutMargins
        = UIEdgeInsetsMake(OWSContactShareView.vMargin, self.hMargin, OWSContactShareView.vMargin, self.hMargin);
    [hStackView addArrangedSubview:avatarView];
    [hStackView addArrangedSubview:labelsView];
    [hStackView addArrangedSubview:disclosureImageView];
    [self addSubview:hStackView];
    [hStackView autoPinToSuperviewEdges];
}

@end

NS_ASSUME_NONNULL_END
