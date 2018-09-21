function message = decodeLSB(stegoImage, nSamples, nBits, isImage, payloadDim, payloadLength)
    % Decoder for LSB method of steganography
    % If payload is an image, generates decoded image in current working directory ('decodedImage.bmp')
    % If payload is a string, the decoded message is stored in 'message' output
    % Currently only works with 8-bit colour depths
    % Alan Ly & Alex Chin, 2018
    %
    % Inputs 
    % stegoImage - the image with an embedded message to be decoded e.g.'BowlCrowd_640_watermarked.bmp'
    % nSamples - number of samples in the image that contain the message...retrieved from the encoder
    % nBits - number of bits per sample/pixel allocated to the message...set by the encoder
    % isImage - whether the payload is an image or string
    % payloadDim - resolution of the payload (if it's an image)
    % payloadLength - no. bits in the payload...used if nBits is odd 
    %
    % Outputs 
    % message - the decoded message (NaN if the payload is an image)
    
    pixelValues = imread(stegoImage);
    pixelValues = de2bi(pixelValues); % binary pixel values 
    
    % Extract message bits from the stegoimage
    counter = 1; 
    if (mod(nBits,2)) %If nBits is odd
        for i = 1: (nSamples-1) 
            message(counter: counter + nBits - 1) = pixelValues(i, 1:nBits);
            counter = counter + nBits; 
        end
        % When nBits is odd, it doesn't divide evenly into payloadLength, so
        % there are leftover bits in the final sample that have to be accounted for
        bitsRemaining = mod(payloadLength,nBits); 
        message(counter : counter + bitsRemaining - 1) = pixelValues(nSamples, 1:bitsRemaining); 
    else
        for i = 1: nSamples 
            message(counter: counter + nBits - 1) = pixelValues(i, 1:nBits);
            counter = counter + nBits; 
        end 
    end 
    
    message = vec2mat(message, 8); % Group the message bits into bytes  
    message = bi2de(message); % convert to decimal
     
    if (isImage) 
        % Generate decoded image
        nPixels = payloadDim(1)*payloadDim(2);
        decodedImage(:,:,1) = vec2mat(message(1 : nPixels), payloadDim(1))';
        decodedImage(:,:,2) = vec2mat(message(nPixels+1 : 2*nPixels), payloadDim(1))'; 
        decodedImage(:,:,3) = vec2mat(message(2*nPixels+1 : 3*nPixels), payloadDim(1))';
        
        imwrite(decodedImage, 'decodedImage.bmp');
        message = nan; 
    else        
        message = char(message)'; % convert into readable characters
    end 
end 