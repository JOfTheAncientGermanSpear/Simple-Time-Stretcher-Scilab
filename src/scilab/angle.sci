function phase = angle(v)
    phase = atan(imag(v), real(v));
endfunction