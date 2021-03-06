    //
    //  imageFilter.m
    //  OpenCViOSDemo
    //
    //  Created by CHARU HANS on 7/6/12.
    //  Copyright (c) 2012 University of Houston - Main Campus. All rights reserved.
    //

    #import "imageFilter.h"
    #import "UIImageCVMatConverter.h"

    @interface imageFilter ()

    @end

    @implementation imageFilter

    - (UIImage *)processImage:(UIImage *)inputImage oldImage:(UIImage *)maskImage number:(int)randomNumber sliderValueOne:(float)valueOne sliderValueTwo:(float)valueTwo
    {
        cv::Mat inputMat = [UIImageCVMatConverter cvMatFromUIImage:inputImage];
        cv::Mat resultMat;
        cv::Mat maskMat;

        switch (randomNumber)
        {
        case 0:
            resultMat = [self pixalizeMatConversion:inputMat pixelValue:(int)valueOne];
            break;
        case 1:
            resultMat = [self cartoonMatConversion:inputMat];
            break;
        case 2:
            resultMat = [self grayMatConversion:inputMat];
            break;
        case 3:
            resultMat = [self softFocusConversion:inputMat];
            break;
        case 4:
            resultMat = [self inverseMatConversion:inputMat];
            break;
        case 5:
            resultMat = [self binaryMatConversion:inputMat thresholdValue:valueOne];
            break;
        case 6:
            resultMat = [self sepiaConversion:inputMat];
            break;
        case 7:
            resultMat = [self pencilSketchConversion:inputMat];
            break;
        case 8:
            resultMat = [self retroEffectConversion:inputMat];
            break;
        case 9: //
            resultMat = [self filmGrainConversion:inputMat];
            break;
        case 10:
            resultMat = [self brightnessContrastEnhanceConversion:inputMat betaValue:valueOne alphaValue:valueTwo];
            break;
        case 11:
            resultMat = [self sketchConversion:inputMat];
            break;
        case 12:
            resultMat = [self pinholeCameraConversion:inputMat];
            break;
        case 13:
            maskMat = [UIImageCVMatConverter cvMatFromUIImage:maskImage];
            resultMat = [self inpaintConversion:inputMat mask:maskMat];
            break;

        default:
            break;
        }
        inputMat.release();

        return [UIImageCVMatConverter UIImageFromCVMat:resultMat];
    }

    - (cv::Mat)pixalizeMatConversion:(cv::Mat)inputMat pixelValue:(int)pixelSize
    {
        // NSLog(@"%d", [self pixelSizeFromFloatValue :thresholdSlider.value] );
        cv::Mat pixelateMat = cv::Mat(inputMat.size(), inputMat.type());
        cv::Vec4b pixelize_bgr, bgrNonPerm;
        pixelize_bgr = inputMat.at<cv::Vec4b>(0, 0);

        for (int x = 0; x < inputMat.cols; x++)
        {
            for (int y = 0; y < inputMat.rows; y++)
            {
                bgrNonPerm = inputMat.at<cv::Vec4b>(y, x);

                for (int c = 0; c < 4; c++)
                    pixelize_bgr[c] = (bgrNonPerm[c] + pixelize_bgr[c]) / 2;

                if (x % pixelSize == pixelSize - 1 && y % pixelSize == pixelSize - 1)
                {
                    for (int r = 0; r < pixelSize; r++)
                    {
                        for (int t = 0; t < pixelSize; t++)
                        {
                            pixelateMat.at<cv::Vec4b>(y - r, x - t) = pixelize_bgr;
                        }
                    }
                    pixelize_bgr = bgrNonPerm;
                }
                else
                {
                    pixelateMat.at<cv::Vec4b>(y, x) = bgrNonPerm;
                }
            }
        }
        inputMat.release();

        return pixelateMat;
    }

    - (cv::Mat)grayMatConversion:(cv::Mat)inputMat
    {
        cv::Mat grayMat;
        cv::cvtColor(inputMat, grayMat, cv::COLOR_BGR2GRAY);
        inputMat.release();
        return grayMat;
    }

    - (cv::Mat)yuvMatConversion:(cv::Mat)inputMat
    {
        cv::Mat yuvMat;
        cv::cvtColor(inputMat, yuvMat, cv::COLOR_BGR2YUV);
        inputMat.release();
        return yuvMat;
    }

    - (cv::Mat)inverseMatConversion:(cv::Mat)inputMat
    {
        cv::cvtColor(inputMat, inputMat, cv::COLOR_BGRA2BGR);
        cv::Mat invertMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());

        // invert image
        cv::bitwise_not(inputMat, invertMat);
        cv::cvtColor(invertMat, invertMat, cv::COLOR_BGR2BGRA);
        inputMat.release();
        return invertMat;
    }

    - (cv::Mat)binaryMatConversion:(cv::Mat)inputMat thresholdValue:(float)threshold
    {
        cv::Mat binaryMat, grayMat;

        cv::cvtColor(inputMat, grayMat, cv::COLOR_BGR2GRAY);
        cv::threshold(grayMat, binaryMat, threshold, 255, cv::THRESH_BINARY);
        grayMat.release();
        inputMat.release();
        return binaryMat;
    }

    - (cv::Mat)sepiaConversion:(cv::Mat)inputMat
    {
        //    cv::Mat sepiaMat = cv::Mat(inputMat.size(), inputMat.type());
        //    cv::Mat kernel = (cv::Mat_<float>(4, 4) <<
        //        0.272, 0.534, 0.131, 0,
        //        0.349, 0.686, 0.168, 0,
        //        0.393, 0.769, 0.189, 0,
        //        0, 0, 0, 1);
        //
        //    cv::transform(inputMat, sepiaMat, kernel);

        cv::Mat sepiaMat;
        cv::Mat sepia = (cv::Mat_<float>(4, 4) <<
                         .131, .534, .272, 0,
                         .168, .686, .349, 0,
                         .189, .769, .393, 0,
                         .0  , .0  , .0  , 1);
        cv::transform(inputMat, sepiaMat, sepia);
        inputMat.release();

        return sepiaMat;
    }

    //http://stackoverflow.com/questions/10595161/convert-an-image-into-color-pencil-sketch-in-opencv

    - (cv::Mat)sketchConversion:(cv::Mat)inputMat
    {

        cv::Mat colorSketchMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());
        cv::Mat grayMat;
        cv::Mat invertMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());
        cv::Mat smoothMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());

        cv::cvtColor(inputMat, inputMat, cv::COLOR_BGRA2BGR);
        // gaussian blur
        cv::GaussianBlur(inputMat, smoothMat, cv::Size(0, 0), 5);
        // invert image
        cv::bitwise_not(smoothMat, invertMat);

        cv::addWeighted(invertMat, 0.5, inputMat, 0.5, 0, inputMat);
        cv::cvtColor(inputMat, inputMat, cv::COLOR_BGR2BGRA);
        // dodge operation
        for (int x = 0; x < inputMat.cols; x++)
        {
            for (int y = 0; y < inputMat.rows; y++)
            {

                for (int c = 0; c < 4; c++)
                    colorSketchMat.at<cv::Vec4b>(y, x)[c] = (inputMat.at<cv::Vec4b>(y, x)[c] == 255 ? 255 : std::min(255, inputMat.at<cv::Vec4b>(y, x)[c] * 255 / (255 - inputMat.at<cv::Vec4b>(y, x)[c])));
            }
        }
        // cv::addWeighted( colorSketchMat, 0.5, inputMat, 0.9, 0, colorSketchMat );
        cv::GaussianBlur(colorSketchMat, colorSketchMat, cv::Size(3, 3), 0);
        inputMat.release();
        invertMat.release();
        smoothMat.release();

        return colorSketchMat;
    }

    - (cv::Mat)pencilSketchConversion:(cv::Mat)inputMat
    {

        cv::Mat pencilMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());
        cv::Mat grayMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());
        cv::Mat invertMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());
        cv::Mat smoothMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());

        cv::cvtColor(inputMat, grayMat, cv::COLOR_BGRA2GRAY);
        // gaussian blur
        cv::GaussianBlur(grayMat, smoothMat, cv::Size(0, 0), 5);
        // invert image
        cv::bitwise_not(smoothMat, invertMat);

        cv::addWeighted(grayMat, 0.5, invertMat, 0.5, 0, grayMat);

        cv::cvtColor(grayMat, grayMat, cv::COLOR_GRAY2BGRA);

        // color dodge
        // b_d = (b_2==255? 255: min(255, b_1*255 /(255- b_2)));
        for (int x = 0; x < inputMat.cols; x++)
        {
            for (int y = 0; y < inputMat.rows; y++)
            {
                for (int c = 0; c < 4; c++)
                {
                    grayMat.at<cv::Vec4b>(y, x)[c] = (grayMat.at<cv::Vec4b>(y, x)[c] == 255 ? 255 : std::min(255, grayMat.at<cv::Vec4b>(y, x)[c] * 255 / (255 - grayMat.at<cv::Vec4b>(y, x)[c])));
                }
            }
        }
        // gaussian blur
        cv::GaussianBlur(grayMat, grayMat, cv::Size(3, 3), 1);

        inputMat.release();
        invertMat.release();
        smoothMat.release();

        return grayMat;
    }

    //http://opencv.willowgarage.com/documentation/cpp/introduction.html

    - (cv::Mat)retroEffectConversion:(cv::Mat)inputMat
    {

        cv::Mat yuvMat, retroMat;
        cv::Mat noise = cv::Mat(inputMat.size(), CV_8U);

        const double brightness = 0;
        const double contrast = 1.7;
        const double color_scale = 0.5;

        // convert image to YUV color space.
        cv::cvtColor(inputMat, yuvMat, cv::COLOR_BGR2YCrCb);

        // split the image into separate color planes
        std::vector<cv::Mat> planes;
        cv::split(yuvMat, planes);

        // fills the matrix with normally distributed random values;
        cv::randn(noise, cv::Scalar::all(150), cv::Scalar::all(20));

        // blur the noise a bit
        cv::GaussianBlur((cv::Mat)noise, (cv::Mat)noise, cv::Size(3, 3), 0.5);

        cv::addWeighted(planes[0], contrast, noise, 1, -128 + brightness, planes[0]);

        planes[1].convertTo(planes[1], planes[1].type(),
                            color_scale, 128 * (1 - color_scale));

        planes[2].convertTo(planes[2], planes[2].type(),
                            color_scale, 128 * (1 - color_scale));

        planes[0] = planes[0].mul(planes[0], 1. / 255);

        // merge the results
        cv::merge(planes, yuvMat);
        // output RGB image
        cv::cvtColor(yuvMat, retroMat, cv::COLOR_YCrCb2BGR);

        inputMat.release();
        yuvMat.release();
        noise.release();
        return retroMat;
    }

    - (cv::Mat)filmGrainConversion:(cv::Mat)inputMat
    {
        cv::Mat yuvMat, filmGrainMat;
        cv::Mat noise = cv::Mat(inputMat.size(), CV_8U);
        // convert image to YUV color space.
        cv::cvtColor(inputMat, yuvMat, cv::COLOR_BGR2YCrCb);
        // split the image into separate color planes
        std::vector<cv::Mat> planes;
        cv::split(yuvMat, planes);
        cv::GaussianBlur((cv::Mat)planes[0], (cv::Mat)planes[0], cv::Size(1, 1), 2);
        // normally distributed random values;
        cv::randu(noise, cv::Scalar::all(0), cv::Scalar::all(255));

        // blur the noise
        cv::GaussianBlur((cv::Mat)noise, (cv::Mat)noise, cv::Size(5, 5), 1);
        cv::addWeighted(planes[0], 1, noise, 0.3, 0, planes[0]);

        planes[1] = planes[0];
        planes[2] = planes[0];
        cv::merge(planes, filmGrainMat);
        cv::cvtColor(filmGrainMat, filmGrainMat, cv::COLOR_BGR2BGRA);
        inputMat.release();
        yuvMat.release();

        return filmGrainMat;
    }

    - (cv::Mat)pinholeCameraConversion:(cv::Mat)inputMat
    {
        cv::Point center;
        double scale = -1.5;
        std::vector<cv::Mat> planes;
        cv::Mat radialMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());

        center = cv::Point(inputMat.rows / 2, inputMat.cols / 2);
        // cv::cvtColor(inputMat, inputMat, cv::COLOR_BGR2GRAY);
        cv::split(inputMat, planes);
        planes[1] = planes[0];
        planes[2] = planes[0];
        cv::merge(planes, inputMat);

        cv::GaussianBlur(inputMat, inputMat, cv::Size(3, 3), 3);

        // cv::cvtColor(inputMat, inputMat, CV_GRAY2BGRA);

        for (int x = 0; x < inputMat.cols; x++)
        {
            for (int y = 0; y < inputMat.rows; y++)
            {
                double dx = (double)(y - center.x) / center.x;
                double dy = (double)(x - center.y) / center.y;
                double weight = exp(((dx * dx + dy * dy)) * scale);
                radialMat.at<cv::Vec4b>(y, x) = (inputMat.at<cv::Vec4b>(y, x) * weight);
            }
        }
        cv::cvtColor(radialMat, radialMat, cv::COLOR_BGRA2BGR);
        inputMat.release();
        return radialMat;
    }

    - (cv::Mat)softFocusConversion:(cv::Mat)inputMat
    {
        cv::Mat softhMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());
        cv::cvtColor(inputMat, inputMat, cv::COLOR_BGRA2BGR);
        // gaussian blur
        cv::GaussianBlur(inputMat, softhMat, cv::Size(0, 0), 25);
        cv::addWeighted(softhMat, 0.6, inputMat, 0.4, 0, softhMat);
        // inputMat.release();
        cv::cvtColor(softhMat, softhMat, cv::COLOR_BGR2BGRA);
        return softhMat;
    }

    - (cv::Mat)brightnessContrastEnhanceConversion:(cv::Mat)inputMat betaValue:(float)beta alphaValue:(float)alpha;
    {
        cv::Mat sauratedMat = cv::Mat(inputMat.rows, inputMat.cols, inputMat.type());

        for (int x = 0; x < inputMat.cols; x++)
        {
            for (int y = 0; y < inputMat.rows; y++)
            {
                for (int c = 0; c < 4; c++)
                    sauratedMat.at<cv::Vec4b>(y, x)[c] = alpha * (inputMat.at<cv::Vec4b>(y, x)[c]) + beta;
            }
        }
        // inputMat.release();
        return sauratedMat;
    }

    - (cv::Mat)inpaintConversion:(cv::Mat)inputMat mask:(cv::Mat)maskMat
    {
        cv::cvtColor(inputMat, inputMat, cv::COLOR_BGRA2BGR);
        cv::cvtColor(maskMat, maskMat, cv::COLOR_BGRA2BGR);

        cv::Mat inpaintMask = cv::Mat::zeros(inputMat.rows, inputMat.cols, CV_8UC1);
        cv::Mat inpaintedMat; // = cv::Mat(inputMat.rows, inputMat.cols,  inputMat.type());
        inpaintedMat = inputMat.clone();
        inpaintMask = maskMat - inputMat;
        cv::cvtColor(inpaintMask, inpaintMask, cv::COLOR_BGR2GRAY);
        cv::threshold(inpaintMask, inpaintMask, 3, 255, cv::THRESH_BINARY);

        cv::inpaint(inputMat, inpaintMask, inpaintedMat, 3, cv::INPAINT_TELEA);
        // cv::cvtColor(inpaintedMat, inpaintedMat, cv::COLOR_BGRA2BGR);
        return inpaintedMat;
    }

    - (cv::Mat)cartoonMatConversion:(cv::Mat)inputMat
    {
        cv::cvtColor(inputMat, inputMat, cv::COLOR_BGRA2BGR);

        cv::Mat cartoonMat, edge;
        cv::Size strel_size;
        strel_size.width = 3;
        strel_size.height = 1;

        // Apply bilateral filter to input image.
        cv::bilateralFilter(inputMat, cartoonMat, 5, 150, 150);
        cv::cvtColor(inputMat, edge, cv::COLOR_BGR2GRAY);
        cv::Canny(edge, edge, 145, 165);
        // Create an elliptical structuring element
        // cv::Mat strel = cv::getStructuringElement(cv::MORPH_DILATE,strel_size);
        // morpholgical smoothing
        // cv::morphologyEx(edgeMap, edgeMap, cv::MORPH_CLOSE, strel);
        // cv::dilate(edge, edge, strel);

        cv::cvtColor(edge, edge, cv::COLOR_GRAY2BGR);
        cv::subtract(cartoonMat, edge, cartoonMat);

        cv::cvtColor(cartoonMat, cartoonMat, cv::COLOR_BGR2BGRA);
        inputMat.release();
        edge.release();

        return cartoonMat;
    }

    @end
