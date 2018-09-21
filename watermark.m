% Watermark
% Alan Ly, 2018 

[stegoImage, originalImage, nSamples, nBits] = encodeLSB('BowlCrowd_640.bmp','testblajblaijfoiejofiaefeiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',7);

message = decodeLSB('BowlCrowd_640_watermarked.bmp', nSamples, nBits);