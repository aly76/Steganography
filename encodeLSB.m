function [stegoImage, originalImg, nSamples, nBits] = encodeLSB(cover, payload, nBits)
    % Encoder for LSB method of steganography
    % Alan Ly & Alex Chin, 2018
    % 
    % Inputs
    % cover - Source image used to carry the message e.g. 'originalImage_640.png'
    % payload - Message to be embedded into the original image 
    % nBits - No. of bits per sample/pixel allocated to the message
    % 
    % Outputs
    % stegoImage - Pixel values of the image with embedded message
    % originalImg - Pixel values of the original image
    % nSamples - Number of samples in the image that contain the message, used by the decoder
    % nBits - Same as above, used by the decoder. Provided for convenience...
    % in reality only the intended receipient of the message would have these
    
    %% Parse function arguments
    [extension, filename] = regexp(cover, '\.\w*', 'match', 'split', 'ignorecase');
    
    supportedFormats = {'.bmp', '.jpg', '.png'};
    findExt = strfind(supportedFormats, extension); 
    supportFlag = 0;
    % Check if file extension is supported
    for i = 1:length(supportedFormats)
        if (findExt{1,i} == 1)
            supportFlag = 1; 
            break;
        end 
    end 
    assert(supportFlag ~= 0, 'The file extension is not supported') 
    
    if (nBits >= 8 || nBits <=0) % function is currently restricted to uint8, behaviour with different colour depths is un-tested
        error('nBits must be between 1 and 7');
    end 
    
    %% Embed payload into cover image
    originalImg = imread(filename{1}, extension{1}(2:end)); 
    
    % Check bits per sample 
    assert(isa(originalImg, 'uint8'), 'Only a 8-bit colour depth is currently supported'); 
    % Add support for other colour depths in future...will have to parse the 
    % class type of the image and then assign bitsPerSample dynamically.
    % Alternatively, can allow the user to input the colour depth as a function
    % argument, but this is not ideal.
    bitsPerSample = 8; 
    
    payload_bin = de2bi(uint8(payload), bitsPerSample)'; % Convert payload to binary ASCII values 
    payload_bin = payload_bin(:); % Concatenate payload into a single column vector
    
    pixelValues = de2bi(originalImg); % binary pixel values
    nSamples = length(payload_bin) / nBits; % Calculate capacity required for payload
    payloadCounter = 1; 
    for i = 1:nSamples 
        pixelValues(i, 1:nBits) = payload_bin(payloadCounter : payloadCounter + nBits - 1); % Embed payload
        payloadCounter = payloadCounter + nBits; 
    end 
    
    % Reconstruct image with embedded message
    pixelValues = bi2de(pixelValues); % uint8 pixel values
    
    imgDim = size(originalImg); 
    nPixels = imgDim(1)*imgDim(2);
    
    stegoImage(:,:,1) = vec2mat(pixelValues(1 : nPixels), imgDim(1))';
    stegoImage(:,:,2) = vec2mat(pixelValues(nPixels+1 : 2*nPixels), imgDim(1))'; 
    stegoImage(:,:,3) = vec2mat(pixelValues(2*nPixels+1 : 3*nPixels), imgDim(1))'; 
    
    imwrite(stegoImage, [filename{1} '_watermarked' extension{1}]);
    
%     j = 1; 
%     k = 1
%     while (sampleNo ~= nSamples)
%         pixelValue = de2bi(originalImg(j,k,1)); % change each decimal value to binary value
%         pixelValue() = payload_bin(rownum, columnnum)
%         embed = [zeros(1,nBits) pixelValue(bitsPerSample-(bitsPerSample-nBits)+1 : end)]; % replace the LSB with 0s | the MSB and LSB is actually flipped
%         stegoImage(j,k,i) = bi2de(embed);
%     end 
%     
%     for j=1:imgDim(1)
%         for k=1:imgDim(2)
%             pixelValue = de2bi(originalImg(j,k,i)); % change each decimal value to binary value
%             embed = [zeros(1,nBits) pixelValue(bitsPerSample-(bitsPerSample-nBits)+1 : end)]; % replace the LSB with 0s | the MSB and LSB is actually flipped
%             stegoImage(j,k,i) = bi2de(embed); % convert back to decimal and place back in image
%         end
%     end
    
       
        
end 