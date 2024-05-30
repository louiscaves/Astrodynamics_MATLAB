% Define a function to return the earth rotation angle given a julian date
function ERA=JD2ERA(JD)
    ERA=mod(280.46061837504 + 360.985612288808 * (JD - 2451545.0), 360);
end