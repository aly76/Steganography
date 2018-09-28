% Watermark
% Alan Ly & Alex Chin, 2018 
clear;
%% Pre-encoding
passage = 'Invisible watermarking involves embedding a message (like an identifier) in an image or video signal which can be read reliably but which is not visible under normal viewing conditions (Google ''steganography'') Ideally, the watermark should be robust to compression, processing and manipulation of the image (eg resampling, addition of noise, ''gentle'' filtering) and yet remain invisible In this project, you will do some research on the topic so you can introduce the principles and some of the approaches to the rest of the group You will also demonstrate your attempt to implement some form of invisible watermarking, including its limits (under what circumstances, whether it be as a result of common processing or deliberate attempts to defeat it, the message is lost) and your attempts to make the system more robust (As a starting point, you could try manipulating the LSBs of the intensity or colour samples, but you might prefer to try something a bit more sophisticated)'; 

%% Encode 

[nSamples, nBits, isImage, payloadDim, payloadLength, imgDim] = encodeLSB('Aerobatics_2000x1500.bmp', 'BowlCrowd_640.bmp', 1);

%% Modifications to the encoded image e.g compression, decimation
 filename = 'Aerobatics_2000x1500_watermarked.bmp';
 i_Array = imread(filename); 
 
%  ref = imread('Aerobatics_2000x1500.bmp'); % Unwatermarked cover image

% Decimate image
Dec_Factor = 3; % Decimation factor 
Dec_counter_i=0;
for i = 1:3 
    for j = 1:imgDim(1)
        Dec_counter_i=Dec_counter_i+1;
            if Dec_counter_i==Dec_Factor
                Dec_counter_i=0;
                Dec_counter_j=0;
                for k=1:imgDim(2)
                    Dec_counter_j=Dec_counter_j+1;
                    if Dec_counter_j==Dec_Factor
                        Dec_counter_j=0;
                    else
                        i_Array(j,k,i)=0;
                    end
                end
            else
                for k=1:imgDim(2)
                    i_Array(j,k,i)=0;
                end
            end
    end
end 

% Gaussian filtering
% i_Array = imgaussfilt(i_Array, 0.5); % s.d. = 0.5 

% AWGN (Additive White Gaussian Noise) 
% i_Array(:,:,1) = awgn(double(i_Array(:,:,1)), 20, 'measured'); 
% i_Array(:,:,2) = awgn(double(i_Array(:,:,2)), 20, 'measured'); 
% i_Array(:,:,3) = awgn(double(i_Array(:,:,3)), 20, 'measured'); 

% PSNR of stegoimage
% psnr(i_Array, ref)

imwrite(i_Array, filename); 
%% Decode

message = decodeLSB('Aerobatics_2000x1500_watermarked.bmp', nSamples, nBits, isImage, payloadDim, payloadLength);

%% Post-decoding 

% PSNR of decoded payload 
refPayload = imread('BowlCrowd_640.bmp'); % Original payload
decPayload = imread('decodedImage.bmp'); % Decoded payload
psnr(decPayload, refPayload) 