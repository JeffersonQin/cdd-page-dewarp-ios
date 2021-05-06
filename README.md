!!! THIS PROJECT IS STILL WORKING IN PROGRESS !!!

# Introduction

This project is an implementation of CDD Model on iOS Platform. We used OpenCV library to handle the image processing work. Since OpenCV is mostly a C++ library, the part of image processing in this project is written in Objective-C++. The interfaces are implemented in Swift, and a bridging file was created to compile the project.

# Compiling

If you want to clone the code and deploy the project on your own computer and cell phones, certain steps have to be followed.

1. The OpenCV library file is not included in the repository due to its large size, and it was added into `.gitignore`. In order to compile the project, you have to [download](https://opencv.org/releases/) the iOS distribution of OpenCV, and add it to the project (or you can just simply place it in the root directory of the project, and Xcode will recognize that).
2. If problems are encountered when compiling the project, check the directory of bridging file in the build settings of the project.
3. This project uses CocoaPods. If you don't know what it is, [click here](https://github.com/CocoaPods/CocoaPods)

# Known Isses

- The floaty menu will not start initially, and you have to scroll about in the tableview to make it appear. This problem is mainly caused by floaty library itself.
- As you can see, we only implemented the core features of the model. More features would be added in further development.

# Migration Progress

The implementation of the model is initially coded in Jupyter Notebook, and the following table shows the migration progress.

|  | Jupyter Notebook | iOS Version |
| - | - | - |
| CDD: Semi-automatic Model | ✅ | ✅ |
| CDD: Segmentation | ✅ | ✅ |
| CDD: Dewarp-v1 | ✅ | ✅ |
| CDD: Dewarp-v2 | ✅ | ✅ (⚠) |
| CDD: Dewarp-v3 | ✅ |  |
| CDD: Page Optimization | ✅ |  |
| RCF Network | ✅ |  |

⚠: There is no free transformation methods in OpenCV library. The implementation here would either be too time-consuming or produce white lines. This would be fixed in further updates, through interpolation methods. 

# Dependencies

- [OpenCV](https://opencv.org/)
- [Floaty](https://github.com/kciter/Floaty)
- [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)

# Contact Me

- Email: 1247006353@qq.com
- QQ, Wechat: 1247006353
- Personal Blog: https://gyrojeff.top/

If you have any problems or advices, feel free to contact me.
