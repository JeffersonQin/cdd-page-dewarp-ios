//
//  PreProcessForPageImage.mm
//  Dewrapper
//
//  Created by Jefferson Qin on 2020/3/31.
//  Copyright © 2020 Jefferson Qin. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "Page Dewarper-Bridging-Header.h"
#import <Foundation/Foundation.h>
#import <JGProgressHUD/JGProgressHUD.h>

using namespace std;
using namespace cv;

namespace DeWarpperConstant {
    const int BINARYZATION_THRESHOLD = 30;
    const int COUNT_OF_SEGMENTS = 300;
};

@implementation JQCV

+ (Mat) getMat:(UIImage *)image :(bool)withAlpha {
    Mat mat; UIImageToMat(image, mat, withAlpha);
    Mat src;
    if (image.imageOrientation == UIImageOrientationLeft) {
        transpose(mat, src);
        flip(src, src, 0);
    } else if (image.imageOrientation == UIImageOrientationRight) {
        transpose(mat, src);
        flip(src, src, 1);
    } else if (image.imageOrientation == UIImageOrientationDown) {
        transpose(mat, src);
        flip(src, src, -1);
    } else if (image.imageOrientation == UIImageOrientationUp) {
        src = mat;
    }
    return src;
}

+ (UIImage *) getImage:(UIImage *)image :(bool)withAlpha {
    Mat mat = [JQCV getMat:image :withAlpha];
    return MatToUIImage(mat);
}

+ (Mat) getSharpened:(Mat)src {
    Mat kernel = (Mat_<char>(3, 3) << 0, -1, 0, -1, 5, -1, 0, -1, 0);
    Mat ret;
    filter2D(src, ret, CV_32F, kernel);
    convertScaleAbs(ret, ret);
    return ret;
}

+ (Mat) getGray:(Mat)src {
    Mat dst;
    cvtColor(src, dst, COLOR_BGR2GRAY);
    return dst;
}

+ (Mat) getSobelX:(Mat)src {
    Mat dst;
    Sobel(src, dst, CV_16S, 1, 0, 3, 1, 0, BORDER_DEFAULT);
    convertScaleAbs(dst, dst);
    return dst;
}

+ (Mat) getSobelY:(Mat)src {
    Mat dst;
    Sobel(src, dst, CV_16S, 0, 1, 3, 1, 0, BORDER_DEFAULT);
    convertScaleAbs(dst, dst);
    return dst;
}

+ (Mat) getSobel:(Mat)src {
    Mat dst;
    addWeighted([JQCV getSobelX:src], 0.5, [JQCV getSobelY:src], 0.5, 0, dst);
    return dst;
}

+ (Mat) getGaussian:(Mat)src {
    Mat dst;
    GaussianBlur(src, dst, cv::Size(3,3), 0, 0, BORDER_DEFAULT);
    return dst;
}

+ (Mat) drawPoint:(Mat) src :(double) x :(double) y {
    Mat dst = src.clone();
    cv::Point p = cv::Point(x, y);
    cv::circle(dst, p, 8, cv::Scalar(0, 255, 0, 255));
    return dst;
}

+ (Mat) drawLine:(Mat) src :(double) x1 :(double) y1 :(double) x2 :(double) y2 {
    Mat dst = src.clone();
    cv::line(dst, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(0, 255, 0, 255), 5);
    cout << dst.type() << endl;
    return dst;
}

+ (UIImage *) getSharpenedImage:(UIImage *)image {
    return MatToUIImage([JQCV getSharpened:[JQCV getMat:image :false]]);
}

+ (UIImage *) getGrayImage:(UIImage *)image {
    return MatToUIImage([JQCV getGray:[JQCV getMat:image :false]]);
}

+ (UIImage *) getGaussianImage:(UIImage *)image {
    return MatToUIImage([JQCV getGaussian:[JQCV getMat:image :false]]);
}

+ (UIImage *) getSobelXImage:(UIImage *)image {
    return MatToUIImage([JQCV getSobelX:[JQCV getMat:image :false]]);
}

+ (UIImage *) getSobelYImage:(UIImage *)image {
    return MatToUIImage([JQCV getSobelY:[JQCV getMat:image :false]]);
}

+ (UIImage *) getSobelImage:(UIImage *)image {
    return MatToUIImage([JQCV getSobel:[JQCV getMat:image :false]]);
}

+ (UIImage *) getNotatedImage:(UIImage *)image :(CGPoint)p_UL :(CGPoint)p_UR :(CGPoint)p_DL :(CGPoint)p_DR :(CGFloat)seperatorThreshold {
    cout << image.size.width << image.size.height << endl;
    Mat src = [JQCV getMat: image :false];
    cout << src.cols << src.rows << endl;
    Mat dst = src.clone();
    cv::Scalar green = cv::Scalar(0, 255, 0, 255);
    cv::circle(dst, cv::Point(p_UL.x, p_UL.y), 20, green, 8);
    cv::circle(dst, cv::Point(p_UR.x, p_UR.y), 20, green, 8);
    cv::circle(dst, cv::Point(p_DL.x, p_DL.y), 20, green, 8);
    cv::circle(dst, cv::Point(p_DR.x, p_DR.y), 20, green, 8);
    cv::line(dst, cv::Point(p_UL.x, p_UL.y), cv::Point(p_UR.x, p_UR.y), green, 8);
    cv::line(dst, cv::Point(p_UR.x, p_UR.y), cv::Point(p_DR.x, p_DR.y), green, 8);
    cv::line(dst, cv::Point(p_DR.x, p_DR.y), cv::Point(p_DL.x, p_DL.y), green, 8);
    cv::line(dst, cv::Point(p_DL.x, p_DL.y), cv::Point(p_UL.x, p_UL.y), green, 8);
    cv::line(dst, cv::Point(1, seperatorThreshold), cv::Point(dst.cols - 2, seperatorThreshold), green, 8);
    return MatToUIImage(dst);
}

+ (UIImage *) getResizedImage:(UIImage *)image :(CGSize) resize :(bool)withAlpha {
    Mat src;
    UIImageToMat(image, src, withAlpha);
    Mat dst;
    cv::resize(src, dst, cv::Size(resize.width, resize.height));
    return MatToUIImage(dst);
}

+ (UIImage *) getPreProcessResult:(UIImage *)image :(UIImage *)mask :(CGFloat)middleSeperator :(CGPoint)p_UL :(CGPoint)p_UR :(CGPoint)p_DL :(CGPoint)p_DR :(JGProgressHUD *)progressHUD {
    // - MARK: Sharpen + Gray + Gaussian + Sobel
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Converting"; });
    Mat src = [JQCV getMat:image :false];
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Cloning"; });
    Mat original = src.clone();
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Sharpening"; });
    Mat sharpened = [JQCV getSharpened:src];
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Converting to Gray"; });
    Mat gray = [JQCV getGray:sharpened];
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Gaussian"; });
    Mat gaussian = [JQCV getGaussian:gray];
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Calculating Sobel"; });
    Mat sobel = [JQCV getSobelY:gaussian];
    // - MARK: MASKING
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Mask Binaryzation"; });
    Mat maskMat; UIImageToMat(mask, maskMat);
    for (int i = 0; i < sobel.rows; i ++) {
        for (int j = 0; j < sobel.cols; j ++) {
            unsigned char *p = maskMat.data + i * sobel.cols * 4 + j * 4;
            if (!(((int) (*p)) == 0 && ((int) (*(p + 1))) == 255 && ((int) (*(p + 2))) == 255 && ((int) (*(p + 3))) == 255)) {
                *(sobel.data + i * sobel.cols + j) = 0;
            }
        }
    }
    // - MARK: BINARYZATION
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Binaryzation Upper"; });
    long long nonBlackCount = 0, nonBlackSum = 0;
    int i = 0;
    for (i = 0; i < middleSeperator * sobel.cols; i ++) {
        if ((* (sobel.data + i)) > DeWarpperConstant::BINARYZATION_THRESHOLD) {
            nonBlackCount ++; nonBlackSum += *(sobel.data + i);
        }
    }
    for (i = 0; i < middleSeperator * sobel.cols; i ++) {
        if ((* (sobel.data + i)) < (double) nonBlackSum / (double) nonBlackCount) {
            *(sobel.data + i) = 0;
        } else {
            *(sobel.data + i) = 255;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Binaryzation Lower"; });
    nonBlackSum = 0; nonBlackCount = 0;
    for (; i < sobel.rows * sobel.cols; i ++) {
        if ((* (sobel.data + i)) > DeWarpperConstant::BINARYZATION_THRESHOLD) {
            nonBlackCount ++; nonBlackSum += *(sobel.data + i);
        }
    }
    for (i = middleSeperator * sobel.cols; i < sobel.rows * sobel.cols; i ++) {
        if ((* (sobel.data + i)) < (double) nonBlackSum / (double) nonBlackCount) {
            *(sobel.data + i) = 0;
        } else {
            *(sobel.data + i) = 255;
        }
    }
    // - MARK: Curve Fitting
    // - MARK: Upper Curve Fitting
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Upper Curve Fitting"; });
    std::vector<cv::Point> upperImageMaskedPointsForCurveFitting;
    for (i = 0; i < middleSeperator; i ++) {
        for (int j = 0; j < sobel.cols; j ++) {
            if (*(sobel.data + i * sobel.cols + j) == 255) {
                upperImageMaskedPointsForCurveFitting.push_back(cv::Point(j, i));
            }
        }
    }
    for (int i = 1; i <= 10; i ++) {
        upperImageMaskedPointsForCurveFitting.push_back(cv::Point(p_UL.x, p_UL.y));
        upperImageMaskedPointsForCurveFitting.push_back(cv::Point(p_UR.x, p_UR.y));
    }
    cv::Mat curveCoefficientMatrix;
    polynomial_curve_fit(upperImageMaskedPointsForCurveFitting, 5, curveCoefficientMatrix);
    std::vector<cv::Point> pointsFittedOnCurve;
    for (int x = p_UL.x; x < p_UR.x; x++) {
        cout << x << endl;
        double y = curveCoefficientMatrix.at<double>(0, 0) + curveCoefficientMatrix.at<double>(1, 0) * x + curveCoefficientMatrix.at<double>(2, 0) * std::pow(x, 2) + curveCoefficientMatrix.at<double>(3, 0) * std::pow(x, 3) + curveCoefficientMatrix.at<double>(4, 0) * std::pow(x, 4) + curveCoefficientMatrix.at<double>(5, 0) * std::pow(x, 5);
        pointsFittedOnCurve.push_back(cv::Point(x, y));
    }
    cv::Point np_UL = cv::Point(p_UL.x, curveCoefficientMatrix.at<double>(0, 0) + curveCoefficientMatrix.at<double>(1, 0) * p_UL.x + curveCoefficientMatrix.at<double>(2, 0) * std::pow(p_UL.x, 2) + curveCoefficientMatrix.at<double>(3, 0) * std::pow(p_UL.x, 3) + curveCoefficientMatrix.at<double>(4, 0) * std::pow(p_UL.x, 4) + curveCoefficientMatrix.at<double>(5, 0) * std::pow(p_UL.x, 5));
    double upperFittedCurveLength = 0.0;
    vector<double> upperApproximateCurveLengthSet;
    upperApproximateCurveLengthSet.push_back(0);
    for (int i = 1; i < pointsFittedOnCurve.size(); i ++) {
        upperFittedCurveLength += std::pow(std::pow(pointsFittedOnCurve[i - 1].y - pointsFittedOnCurve[i].y, 2) + 1, 0.5);
        upperApproximateCurveLengthSet.push_back(upperFittedCurveLength);
    }
    
    double upperFittedCurveUnitLengthForEachSegment = upperFittedCurveLength / (double) DeWarpperConstant::COUNT_OF_SEGMENTS;
    
    vector<cv::Point2f> upperCroppingKeyPointsOnCurve;
    
    int j = 1;
    upperCroppingKeyPointsOnCurve.push_back(cv::Point2f(np_UL.x, np_UL.y));
    for (int i = 0; i < upperApproximateCurveLengthSet.size(); i ++) {
        if (upperApproximateCurveLengthSet[i] >= upperFittedCurveUnitLengthForEachSegment * j) {
            upperCroppingKeyPointsOnCurve.push_back(cv::Point2f(pointsFittedOnCurve[i].x, pointsFittedOnCurve[i].y));
            j ++;
        }
    }
    
    // lower
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Lower Curve Fitting"; });
    std::vector<cv::Point> lowerImageMaskedPointsForCurveFitting;
    for (i = middleSeperator; i < sobel.rows; i ++) {
        for (int j = 0; j < sobel.cols; j ++) {
            if (*(sobel.data + i * sobel.cols + j) == 255) {
                lowerImageMaskedPointsForCurveFitting.push_back(cv::Point(j, i));
            }
        }
    }
    for (int i = 1; i <= 10; i ++) {
        lowerImageMaskedPointsForCurveFitting.push_back(cv::Point(p_DL.x, p_DL.y));
        lowerImageMaskedPointsForCurveFitting.push_back(cv::Point(p_DR.x, p_DR.y));
    }
    
    curveCoefficientMatrix = cv::Mat();
    polynomial_curve_fit(lowerImageMaskedPointsForCurveFitting, 5, curveCoefficientMatrix);
    
    pointsFittedOnCurve = std::vector<cv::Point>();
    for (int x = p_DL.x; x < p_DR.x; x++) {
        cout << x << endl;
        double y = curveCoefficientMatrix.at<double>(0, 0) + curveCoefficientMatrix.at<double>(1, 0) * x + curveCoefficientMatrix.at<double>(2, 0) * std::pow(x, 2) + curveCoefficientMatrix.at<double>(3, 0) * std::pow(x, 3) + curveCoefficientMatrix.at<double>(4, 0) * std::pow(x, 4) + curveCoefficientMatrix.at<double>(5, 0) * std::pow(x, 5);
        pointsFittedOnCurve.push_back(cv::Point(x, y));
    }
    cv::Point np_DL = cv::Point(p_DL.x, curveCoefficientMatrix.at<double>(0, 0) + curveCoefficientMatrix.at<double>(1, 0) * p_DL.x + curveCoefficientMatrix.at<double>(2, 0) * std::pow(p_DL.x, 2) + curveCoefficientMatrix.at<double>(3, 0) * std::pow(p_DL.x, 3) + curveCoefficientMatrix.at<double>(4, 0) * std::pow(p_DL.x, 4) + curveCoefficientMatrix.at<double>(5, 0) * std::pow(p_DL.x, 5));
    
    double lowerFittedCurveLength = 0.0;
    vector<double> lowerApproximateCurveLengthSet;
    lowerApproximateCurveLengthSet.push_back(0);
    for (int i = 1; i < pointsFittedOnCurve.size(); i ++) {
        lowerFittedCurveLength += std::pow(std::pow(pointsFittedOnCurve[i - 1].y - pointsFittedOnCurve[i].y, 2) + 1, 0.5);
        lowerApproximateCurveLengthSet.push_back(lowerFittedCurveLength);
    }
    
    double lowerUnitLength = lowerFittedCurveLength / (double) DeWarpperConstant::COUNT_OF_SEGMENTS;
    
    vector<cv::Point2f> lowerKeyBorderPoints;
    
    j = 1;
    lowerKeyBorderPoints.push_back(Point2f(np_DL.x, np_DL.y));
    for (int i = 0; i < lowerApproximateCurveLengthSet.size(); i ++) {
        if (lowerApproximateCurveLengthSet[i] >= lowerUnitLength * j) {
            lowerKeyBorderPoints.push_back(cv::Point2f(pointsFittedOnCurve[i].x, pointsFittedOnCurve[i].y));
//            circle(src, points_fitted[i], 10, Scalar(255, 0, 0, 255));
            j ++;
        }
    }
    
    cout << "Upper Length: " << upperFittedCurveLength << endl << "Lower Length: " << lowerFittedCurveLength << endl;
    
    // 貌似很神奇的仿射变换（没有考虑纵向透视的情况）
    Mat ret;
    
    Mat affine_upper_mask(cv::Size(7, 2850), original.type(), cv::Scalar(255, 255, 255, 255));
    Mat affine_lower_mask;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Changing"; });
    Mat affine_upper;
    
    std::vector<cv::Point2f> src_corners_affine, dst_corners_affine;
    std::vector<cv::Point> poly_corners_affine;
    src_corners_affine.push_back(upperCroppingKeyPointsOnCurve[0]);
    src_corners_affine.push_back(upperCroppingKeyPointsOnCurve[1]);
    src_corners_affine.push_back(lowerKeyBorderPoints[0]);
    dst_corners_affine.push_back(cv::Point2f(0, 0));
    dst_corners_affine.push_back(cv::Point2f(7, 0));
    dst_corners_affine.push_back(cv::Point2f(0, 2850));
    poly_corners_affine.push_back(cv::Point(7, 2850));
    poly_corners_affine.push_back(cv::Point(7, 0));
    poly_corners_affine.push_back(cv::Point(0, 2850));
    
    
    cv::warpAffine(original, affine_upper, cv::getAffineTransform(src_corners_affine, dst_corners_affine), cv::Size(7, 2850), BORDER_REFLECT_101);
    
    cv::fillConvexPoly(affine_upper_mask, poly_corners_affine, cv::Scalar(0, 0, 0, 0), 4);
    bitwise_not(affine_upper_mask, affine_lower_mask);
    cv::bitwise_and(affine_upper_mask, affine_upper, affine_upper);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        progressHUD.textLabel.text = @"Affining Upper";
        progressHUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] init];
        progressHUD.progress = .0f;
    });
    
    
    for (int i = 2; i <= DeWarpperConstant::COUNT_OF_SEGMENTS; i ++) {
        std::vector<cv::Point2f> src_corners_affine, dst_corners_affine;
        std::vector<cv::Point> poly_corners_affine;
        cv::Mat affine;
        src_corners_affine.push_back(upperCroppingKeyPointsOnCurve[i - 1]);
        src_corners_affine.push_back(upperCroppingKeyPointsOnCurve[i]);
        src_corners_affine.push_back(lowerKeyBorderPoints[i - 1]);
        dst_corners_affine.push_back(cv::Point2f(0, 0));
        dst_corners_affine.push_back(cv::Point2f(7, 0));
        dst_corners_affine.push_back(cv::Point2f(0, 2850));
        poly_corners_affine.push_back(cv::Point(7, 2850));
        poly_corners_affine.push_back(cv::Point(7, 0));
        poly_corners_affine.push_back(cv::Point(0, 2850));
        cv::warpAffine(original, affine, cv::getAffineTransform(src_corners_affine, dst_corners_affine), cv::Size(7, 2850), BORDER_REFLECT_101);
        cv::bitwise_and(affine, affine_upper_mask, affine);
        cv::hconcat(affine_upper, affine, affine_upper);
        dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.progress = (double) i / (double) DeWarpperConstant::COUNT_OF_SEGMENTS; });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.textLabel.text = @"Affining Lower"; });
    
    Mat affine_lower;
    
    src_corners_affine = std::vector<cv::Point2f>(); dst_corners_affine = std::vector<cv::Point2f>();
    poly_corners_affine = std::vector<cv::Point>();
    src_corners_affine.push_back(upperCroppingKeyPointsOnCurve[1]);
    src_corners_affine.push_back(lowerKeyBorderPoints[0]);
    src_corners_affine.push_back(lowerKeyBorderPoints[1]);
    dst_corners_affine.push_back(cv::Point2f(7, 0));
    dst_corners_affine.push_back(cv::Point2f(0, 2850));
    dst_corners_affine.push_back(cv::Point2f(7, 2850));
    poly_corners_affine.push_back(cv::Point(0, 0));
    poly_corners_affine.push_back(cv::Point(7, 0));
    poly_corners_affine.push_back(cv::Point(0, 2850));
    cv::warpAffine(original, affine_lower, cv::getAffineTransform(src_corners_affine, dst_corners_affine), cv::Size(7, 2850), BORDER_REFLECT_101);
    cv::bitwise_and(affine_lower_mask, affine_lower, affine_lower);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        progressHUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
        progressHUD.progress = .0f;
    });
    
    for (int i = 2; i <= DeWarpperConstant::COUNT_OF_SEGMENTS; i ++) {
        std::vector<cv::Point2f> src_corners_affine, dst_corners_affine;
        std::vector<cv::Point> poly_corners_affine;
        cv::Mat affine;
        src_corners_affine.push_back(upperCroppingKeyPointsOnCurve[i]);
        src_corners_affine.push_back(lowerKeyBorderPoints[i - 1]);
        src_corners_affine.push_back(lowerKeyBorderPoints[i]);
        dst_corners_affine.push_back(cv::Point2f(7, 0));
        dst_corners_affine.push_back(cv::Point2f(0, 2850));
        dst_corners_affine.push_back(cv::Point2f(7, 2850));
        poly_corners_affine.push_back(cv::Point(0, 0));
        poly_corners_affine.push_back(cv::Point(7, 0));
        poly_corners_affine.push_back(cv::Point(0, 2850));
        cv::warpAffine(original, affine, cv::getAffineTransform(src_corners_affine, dst_corners_affine), cv::Size(7, 2850), BORDER_REFLECT_101);
        cv::bitwise_and(affine_lower_mask, affine, affine);
        cv::hconcat(affine_lower, affine, affine_lower);
        dispatch_async(dispatch_get_main_queue(), ^{ progressHUD.progress = (double) i / (double) DeWarpperConstant::COUNT_OF_SEGMENTS; });
    }
    
    cv::add(affine_lower, affine_upper, ret);
    
    
    
    
    
    // 考虑纵向透视的仿射变换
    
    const double PAPER_WIDTH = 2100, PAPER_HEIGHT = 2850;

//
//    Mat perspectiveRet(cv::Size(PAPER_WIDTH, PAPER_HEIGHT), original.type(), cv::Scalar(0, 0, 0, 0));
//    Mat perspectiveAffineRet;
//
//    if (upperLength < lowerLength) {
//        double affineUpperLength = PAPER_WIDTH / lowerLength * upperLength;
//        double affineLowerLength = PAPER_WIDTH;
//        double affineUpperStartPoint = (affineLowerLength - affineUpperLength) / 2;
//        double affineUpperUnitLength = affineUpperLength / (double) COUNT_OF_SEGMENTS;
//        double affineLowerUnitLength = affineLowerLength / (double) COUNT_OF_SEGMENTS;
//        std::vector<cv::Mat> affineUpperMasks, affineLowerMasks;
//        for (int i = 1; i <= COUNT_OF_SEGMENTS; i ++) {
//            cv::Mat lowerMaskTmp(cv::Size(PAPER_WIDTH, PAPER_HEIGHT), original.type(), cv::Scalar(0, 0, 0, 0));
//            cv::Mat upperMaskTmp(cv::Size(PAPER_WIDTH, PAPER_HEIGHT), original.type(), cv::Scalar(255, 255, 255, 255));
//            std::vector<cv::Point> lowerMaskTrianglePoints, upperMaskLeftPoints, upperMaskRightPoints;
//            lowerMaskTrianglePoints.push_back(cv::Point(affineLowerUnitLength * (i - 1), PAPER_HEIGHT));
//            lowerMaskTrianglePoints.push_back(cv::Point(affineLowerUnitLength * i, PAPER_HEIGHT));
//            lowerMaskTrianglePoints.push_back(cv::Point(affineUpperStartPoint + affineUpperUnitLength * i));
//            cv::fillConvexPoly(lowerMaskTmp, lowerMaskTrianglePoints, cv::Scalar(255, 255, 255, 255), 4);
//            affineLowerMasks.push_back(lowerMaskTmp);
//            upperMaskLeftPoints.push_back(cv::Point(0, 0));
//            upperMaskLeftPoints.push_back(cv::Point(affineUpperStartPoint + affineUpperUnitLength * (i - 1), 0));
//            upperMaskLeftPoints.push_back(cv::Point(affineLowerUnitLength * (i - 1), PAPER_HEIGHT));
//            upperMaskLeftPoints.push_back(cv::Point(0, PAPER_HEIGHT));
//            cv::fillConvexPoly(upperMaskTmp, upperMaskLeftPoints, cv::Scalar(0, 0, 0, 0), 4);
//            upperMaskRightPoints.push_back(cv::Point(affineUpperStartPoint + affineUpperUnitLength * i, 0));
//            upperMaskRightPoints.push_back(cv::Point(PAPER_WIDTH, 0));
//            upperMaskRightPoints.push_back(cv::Point(PAPER_WIDTH, PAPER_HEIGHT));
//            upperMaskRightPoints.push_back(cv::Point(affineLowerUnitLength * (i - 1), PAPER_HEIGHT));
//            cv::fillConvexPoly(upperMaskTmp, upperMaskRightPoints, cv::Scalar(0, 0, 0, 0), 4);
//            affineUpperMasks.push_back(upperMaskTmp);
//        }
//        for (int i = 1; i <= COUNT_OF_SEGMENTS; i ++) {
//            cv::Mat affineUpperTmp;
//            std::vector<cv::Point2f> affineUpperSrcCorners, affineUpperDstCorners;
//            affineUpperSrcCorners.push_back(upperKeyBorderPoints[i - 1]);
//            affineUpperSrcCorners.push_back(upperKeyBorderPoints[i]);
//            affineUpperSrcCorners.push_back(lowerKeyBorderPoints[i - 1]);
//            affineUpperDstCorners.push_back(cv::Point2f(affineUpperStartPoint + affineUpperUnitLength * (i - 1), 0));
//            affineUpperDstCorners.push_back(cv::Point2f(affineUpperStartPoint + affineUpperUnitLength * i, 0));
//            affineUpperDstCorners.push_back(cv::Point2f(affineLowerUnitLength * (i - 1), PAPER_HEIGHT));
//            cv::warpAffine(original, affineUpperTmp, cv::getAffineTransform(affineUpperSrcCorners, affineUpperDstCorners), cv::Size(PAPER_WIDTH, PAPER_HEIGHT), BORDER_REFLECT_101);
////            UIImageWriteToSavedPhotosAlbum(MatToUIImage(affineUpperTmp), nil, nil, nil);
//            cv::bitwise_and(affineUpperMasks[i - 1], affineUpperTmp, affineUpperTmp);
//            cv::add(perspectiveRet, affineUpperTmp, perspectiveRet);
//            cout << "up: " << i << endl;
//        }
//        for (int i = 1; i <= COUNT_OF_SEGMENTS; i ++) {
//            cv::Mat affineLowerTmp;
//            std::vector<cv::Point2f> affineLowerSrcCorners, affineLowerDstCorners;
//            affineLowerSrcCorners.push_back(upperKeyBorderPoints[i]);
//            affineLowerSrcCorners.push_back(lowerKeyBorderPoints[i - 1]);
//            affineLowerSrcCorners.push_back(lowerKeyBorderPoints[i]);
//            affineLowerDstCorners.push_back(cv::Point2f(affineUpperStartPoint + affineUpperUnitLength * i, 0));
//            affineLowerDstCorners.push_back(cv::Point2f(affineLowerUnitLength * (i - 1), PAPER_HEIGHT));
//            affineLowerDstCorners.push_back(cv::Point2f(affineLowerUnitLength * i, PAPER_HEIGHT));
//            cv::warpAffine(original, affineLowerTmp, cv::getAffineTransform(affineLowerSrcCorners, affineLowerDstCorners), cv::Size(PAPER_WIDTH, PAPER_HEIGHT), BORDER_REFLECT_101);
////            UIImageWriteToSavedPhotosAlbum(MatToUIImage(affineLowerTmp), nil, nil, nil);
//            cv::bitwise_and(affineLowerMasks[i - 1], affineLowerTmp, affineLowerTmp);
//            cv::add(perspectiveRet, affineLowerTmp, perspectiveRet);
//            cout << "low: " << i << endl;
//        }
//        std::vector<cv::Point2f> perspectiveSrcCorners, perspectiveDstCorners;
//        perspectiveSrcCorners.push_back(cv::Point2f(affineUpperStartPoint, 0));
//        perspectiveSrcCorners.push_back(cv::Point2f(affineUpperStartPoint + COUNT_OF_SEGMENTS * affineUpperUnitLength, 0));
//        perspectiveSrcCorners.push_back(cv::Point2f(0, PAPER_HEIGHT));
//        perspectiveSrcCorners.push_back(cv::Point2f(PAPER_WIDTH, PAPER_HEIGHT));
//        perspectiveDstCorners.push_back(cv::Point2f(0, 0));
//        perspectiveDstCorners.push_back(cv::Point2f(PAPER_WIDTH, 0));
//        perspectiveDstCorners.push_back(cv::Point2f(0, PAPER_HEIGHT));
//        perspectiveDstCorners.push_back(cv::Point2f(PAPER_WIDTH, PAPER_HEIGHT));
//        cv::warpPerspective(perspectiveRet, perspectiveAffineRet, cv::getPerspectiveTransform(perspectiveSrcCorners, perspectiveDstCorners), cv::Size(PAPER_WIDTH, PAPER_HEIGHT));
//    }
    
    
    return MatToUIImage(ret);
}


bool polynomial_curve_fit(std::vector<cv::Point>& key_point, int n, cv::Mat& A) {
    long long N = key_point.size();
    cv::Mat X = cv::Mat::zeros(n + 1, n + 1, CV_64FC1);
    for (int i = 0; i < n + 1; i ++)
        for (int j = 0; j < n + 1; j++)
            for (int k = 0; k < N; k++)
                    X.at<double>(i, j) = X.at<double>(i, j) + std::pow(key_point[k].x, i + j);
    cv::Mat Y = cv::Mat::zeros(n + 1, 1, CV_64FC1);
    for (int i = 0; i < n + 1; i ++)
        for (int k = 0; k < N; k ++)
            Y.at<double>(i, 0) = Y.at<double>(i, 0) + std::pow(key_point[k].x, i) * key_point[k].y;
    A = cv::Mat::zeros(n + 1, 1, CV_64FC1);
    cv::solve(X, Y, A, cv::DECOMP_LU);
    return true;
}

double angle(cv::Point pt1, cv::Point pt2, cv::Point pt0)
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2) / sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

+ (NSMutableArray *) largestRect:(UIImage *)image {
    Mat src = [JQCV getMat:image :false];
    Mat hsv;
    cvtColor(src, hsv, COLOR_BGR2HSV);
    vector<Mat> channels;
    split(hsv, channels);
    vector<cv::Point> rect;
    double maxArea = 0.0;
    for (int i = 0; i <= 90; i += 1) {
        // 提取 Hue 通道
        Mat binaryImage = channels[1] < i;
        // 如果超过 70% 的像素都变白了，那么阈值化过头了，直接退出
        if (countNonZero(binaryImage) > src.rows * src.cols * 0.7) {
            break;
        }
        // 找到连通区域
        vector<vector<cv::Point> > contours;
        findContours(binaryImage, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
        // 多边形近似
        for (int i = 0; i < contours.size(); ++ i) {
            vector<cv::Point> polygon;
            approxPolyDP(contours[i], polygon, arcLength(contours[i], 1) * 0.02, 1);
            double area = fabs(contourArea(polygon));
            // 把不可能是矩形的区域丢掉
            if (isContourConvex(polygon) && polygon.size() == 4 && area > maxArea) {
                double maxCosine = 0;
                for (int j = 2; j < 5; j ++) {
                    double cosine = fabs(angle(polygon[j % 4], polygon[j - 2], polygon[j - 1]));
                    maxCosine = MAX(maxCosine, cosine);
                }
                if (maxCosine < 0.3) {
                    maxArea = area;
                    rect = polygon;
                }
            }
        }
    }
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (int i = 0; i < rect.size(); i ++) {
        [array addObject: @(rect[i].x)]; [array addObject: @(rect[i].y)];
    }
    return array;
}

@end
