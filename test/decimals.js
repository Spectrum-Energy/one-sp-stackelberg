const decimals = 12;

const fromDecimalToFixed = (array) => {
    return array.map(number => (number * Math.pow(10,decimals)).toLocaleString('fullwide', { useGrouping: false, maximumFractionDigits: 0 }));
}

const fromFixedToDecimal = (array) => {
    return array.map(number => parseInt(number) / Math.pow(10, decimals));
}

const roundNumber = (number, decimalPlaces = 4) => {
    const factorOfTen = Math.pow(10, decimalPlaces);
    return Math.round(number * factorOfTen) / factorOfTen;
}

const roundArray = (array, decimalPlaces = 4) => {
    return array.map(number => roundNumber(number, decimalPlaces))
};

module.exports = {
    fromDecimalToFixed,
    fromFixedToDecimal,
    roundArray
}