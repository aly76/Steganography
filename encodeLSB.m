function [stegoImage, originalImg] = encodeLSB(cover, payload, nBits)
    % LSB method of steganography
    % Alex Chin & Alan Ly, 2018
    
    % Parse function arguments
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
    
    originalImg = imread(filename{1}, extension{1}(2:end)); 
    % Check bits per sample 
    assert(isa(originalImg, 'uint8'), 'Only a 8-bit colour depth is currently supported'); % Add support for other colour depths in future
    bitsPerSample = 8; 
    
    imgDim = size(originalImg); 
    stegoImage = zeros(imgDim(1), imgDim(2), imgDim(3));
    for i=1:imgDim(3) % Does not work for grayscale images yet 
        for j=1:imgDim(1)
            for k=1:imgDim(2)
                pixelValue = de2bi(originalImg(j,k,i)); % change each decimal value to binary value
                embed = [zeros(1,nBits) pixelValue(bitsPerSample-(bitsPerSample-nBits)+1 : end)]; % replace the LSB with 0s | the MSB and LSB is actually flipped
                stegoImage(j,k,i) = bi2de(embed); % convert back to decimal and place back in image
            end
        end
    end
       
        
end 