const LoadApi = function ( ) {
    var url = 'https://sleepy-beach-19067.herokuapp.com/get_paypalkey';

    return fetch(url , {
        method : 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    }).then( resp => resp.json() );
}

export { LoadApi };