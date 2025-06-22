# EyeBlinkDetectionNonML

EyeBlinkDetectionNonML is an application for detecting eye blinks using Vision and the Eye Aspect Ratio (EAR) algorithm, implemented in Swift. This approach utilizes Apple's Vision framework for facial landmark detection and computes blinks using a geometric formula, without the need for machine learning.

## Features

- Real-time eye blink detection using the device camera.
- Pure geometric method with no machine learning required.
- Uses Vision for facial and landmark detection.
- Lightweight, fast, and interpretable.
- Simple and user-friendly interface.

## Technologies Used

- **Swift**: Main programming language.
- **Vision**: For face and landmark detection.

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/ammarsufyan/EyeBlinkDetectionNonML.git
   ```

2. Open the `EyeBlinkDetectionNonML.xcodeproj` project in Xcode.

3. Run the project on a macOS device.

## How It Works

1. The app accesses the camera and detects faces and eye landmarks using Vision.
2. EAR (Eye Aspect Ratio) is calculated based on the positions of six eye landmarks.
3. A blink is detected when the EAR drops below a set threshold, as seen in the EAR graph.

### Eye Aspect Ratio (EAR) Formula

The EAR is given by:

![unnamed-1](https://github.com/user-attachments/assets/7a1c3c32-9471-4fc0-ac8e-c7a38e58f536)

Where \( p_1, p_2, ..., p_6 \) are the coordinates of the six eye landmarks.

### Visual Illustration

The following illustrates the EAR calculation and landmark positions:

![unnamed](https://github.com/user-attachments/assets/e3fd6cd2-0996-45d4-9c40-0c279e455027)

- The red points are eye landmarks used in the formula.
- The graph below shows the EAR signal, with a dip corresponding to a blink.

## Contributing

Contributions are welcome! Please fork this repository and submit a pull request for any features or bug fixes.

## License

This project is licensed under the MIT License.

---

**Contact:**  
[ammarsufyan](https://github.com/ammarsufyan)
