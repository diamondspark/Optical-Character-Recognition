function [ output_args ] = Write_on_image_blue( loc,predictedclass )

    % Writing Predicted class
    if(predictedclass==1)
    text(loc(1),loc(2),'a','color','blue');
    elseif(predictedclass==2)
    text(loc(1),loc(2),'d','color','blue');
    elseif(predictedclass==3)
    text(loc(1),loc(2),'f','color','blue');
    elseif(predictedclass==4)
    text(loc(1),loc(2),'h','color','blue');
    elseif(predictedclass==5)
    text(loc(1),loc(2),'k','color','blue');
    elseif(predictedclass==6)
    text(loc(1),loc(2),'m','color','blue');
    elseif(predictedclass==7)
    text(loc(1),loc(2),'n','color','blue');
    elseif(predictedclass==8)
    text(loc(1),loc(2),'o','color','blue');
    elseif(predictedclass==9)
    text(loc(1),loc(2),'p','color','blue');
    elseif(predictedclass==10)
    text(loc(1),loc(2),'q','color','blue');
    elseif(predictedclass==11)
    text(loc(1),loc(2),'r','color','blue');
    elseif(predictedclass==12)
    text(loc(1),loc(2),'s','color','blue');
    elseif(predictedclass==13)
    text(loc(1),loc(2),'u','color','blue');
    elseif(predictedclass==14)
    text(loc(1),loc(2),'w','color','blue');
    elseif(predictedclass==15)
    text(loc(1),loc(2),'x','color','blue');
    elseif(predictedclass==16)
    text(loc(1),loc(2),'z','color','blue');
    end
end

