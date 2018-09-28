% Watermark
% Alan Ly & Alex Chin, 2018 

%% Encode 

[nSamples, nBits, isImage, payloadDim, payloadLength] = encodeLSB('Aerobatics_2000x1500.bmp','BowlCrowd_640.bmp',7);

%% Modifications to the encoded image e.g compression 



%% Decode

message = decodeLSB('Aerobatics_2000x1500_watermarked.bmp', nSamples, nBits, isImage, payloadDim, payloadLength);