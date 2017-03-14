switch EP.Data{evt,1}
    case 'Free'
        LeftHand.Draw;
        RightHand.Draw;
    case 'Right'
        RightHand.Draw;
    case 'Left'
        LeftHand.Draw;
    case 'Sequence'
        LeftHand.Draw;
    otherwise
end
