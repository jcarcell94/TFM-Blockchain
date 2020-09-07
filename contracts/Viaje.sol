pragma solidity ^0.5.11; 

import '../Libraries/Ownable.sol';

contract Viaje is Ownable{
    
    address public barcoDir; // Direccion del contrato del barco
    address public viajeDir; // Direccion del contrato del viaje
    Faena viaje; 

    // Estructura de datos del viaje
    enum EstadoBarco {amarrado, saliendo, pescando, regresando}
    enum EstadoViaje {noiniciado, encurso, finalizado, revision, novalido}

    struct Faena{
        uint ID; //ID único del viaje
        string empresa;
        string puertoIni; //puerto de salida
        string puertoFinalEst; //puerto final establecido
        string puertoFinalReal; //puerto final real
        string proposito; //propósito del viaje
        bytes32 [] localizacion; //localización de la embarcacion (latitud/longitud)
        uint [] timeLocalizacion; //timestamp del registro de la localización
        uint [] horaLocal;  //hora local de la embarcación
        EstadoBarco estadoBarco;
        bytes32 [] velRumbo; //velocidad/rumbo
        bytes32 [] area; //área geográfica en la que se encuentra
        bytes32 [] weather; //estado atmosférico
        
        //noiniciado: smart contract levantado pero el barco no ha salido
        //encurso: el barco se encuentra en proceso de viaje y pesca
        //finalizado: el barco ha finalizado satisfactoriamente el viaje
        //revision: el smart contract se encuentra en proceso de verificación para pasar a finalizado
        //novalido: después de revisado o procesado posteriormente este smart contract queda anulado
        EstadoViaje estadoViaje;
    }

   // Eventos
    event travelCreated(address indexed owner, address indexed viajeDir);
    event dataUploaded(address indexed owner, address indexed viajeDir);
    
    //Creación del Viaje
    constructor (uint _ID, string memory _empresa, string memory _puertoIni, string memory _puertoFinalEst, string memory _proposito, address _barcoDir) public{
        viajeDir = address(this);
        barcoDir = _barcoDir;
        viaje.ID = _ID;
        viaje.empresa = _empresa;
        viaje.puertoIni = _puertoIni;
        viaje.puertoFinalEst = _puertoFinalEst;
        viaje.puertoFinalReal = "None";
        viaje.proposito = _proposito;
        /// viaje.localizacion.push(0x0); 
        /// viaje.timeLocalizacion.push(0);
        /// viaje.horaLocal.push(0);
        viaje.estadoBarco = EstadoBarco.amarrado;
        /// viaje.velRumbo.push(0x0);
        /// viaje.area.push(0x0);
        /// viaje.weather.push(0x0);
        viaje.estadoViaje= EstadoViaje.noiniciado;
        emit travelCreated(msg.sender, viajeDir);
    }

    // Refresco de los datos del viaje
    function uploadData(bytes32  _localizacion, uint _timeLocalizacion, uint _horaLocal, bytes32  _velRumbo, bytes32  _area, bytes32  _weather) onlyOwner public{
        require(viaje.estadoViaje == EstadoViaje.encurso, 'El viaje no se encuentra en curso');
        viaje.localizacion.push(_localizacion);
        viaje.timeLocalizacion.push(_timeLocalizacion);
        viaje.horaLocal.push(_horaLocal);
        viaje.velRumbo.push(_velRumbo);
        viaje.area.push(_area);
        viaje.weather.push(_weather);
        emit dataUploaded(msg.sender, viajeDir);
    }

    // Getter de datos principales del viaje
    function getViaje() public view returns (uint _ID, string memory _puertoIni, string memory _proposito, string memory _estadoViaje, string memory estadoBarco){
        return (viaje.ID, viaje.puertoIni, viaje.proposito, getStatusViaje(), getStatusBarco());
    }

    // Devuelve los datos de la ruta (localización, velocidad rumbo...)
    function getRoute() public view returns (uint [] memory _timeLocalizacion, uint [] memory _horaLocal, bytes32[] memory _localizacion, bytes32[] memory _velRumbo, bytes32[] memory _area, bytes32[] memory _weather){
        require(viaje.estadoViaje != EstadoViaje.noiniciado);
        return (viaje.timeLocalizacion, viaje.horaLocal, viaje.localizacion, viaje.velRumbo, viaje.area, viaje.weather);
    }

    //Devuelve la última localizacion
    function getLocalization() public view returns(bytes32  _localizacion){
        require(viaje.estadoViaje != EstadoViaje.noiniciado);
        return viaje.localizacion[viaje.localizacion.length];
    }

    // Cambio de estado VIAJE no iniciado -> en curso
    function startTravel() onlyOwner public{
        require (viaje.estadoViaje == EstadoViaje.noiniciado, 'El viaje debe de estar no iniciado');
        viaje.estadoViaje = EstadoViaje.encurso;
        viaje.estadoBarco = EstadoBarco.saliendo;
    }
    
    function getStatusViaje () public view returns (string memory _estadoViaje) {
        if (viaje.estadoViaje == EstadoViaje.encurso) return "En curso";
        if (viaje.estadoViaje == EstadoViaje.noiniciado) return "No iniciado";
        if (viaje.estadoViaje == EstadoViaje.finalizado) return "Finalizado";
        if (viaje.estadoViaje == EstadoViaje.revision) return "Revisión";
        if (viaje.estadoViaje == EstadoViaje.novalido) return "No valido";
    }

    function getStatusBarco () public view returns (string memory _estadoBarco) {
        if (viaje.estadoBarco == EstadoBarco.amarrado) return "Amarrado";
        if (viaje.estadoBarco == EstadoBarco.amarrado) return "Saliendo";
        if (viaje.estadoBarco == EstadoBarco.amarrado) return "Pescando";
        if (viaje.estadoBarco == EstadoBarco.amarrado) return "Regresando";
    }
    
    // Cambio de estado VIAJE en curso -> revision
    function reviewTravel() onlyOwner public{
        require (viaje.estadoViaje == EstadoViaje.encurso, 'El viaje debe de estar en curso');
        viaje.estadoViaje = EstadoViaje.revision;
        viaje.estadoBarco = EstadoBarco.amarrado;
    }

    // Cambio de estado VIAJE revision -> finalizado
    function endTravel() onlyOwner public{
        require (viaje.estadoViaje == EstadoViaje.revision, 'El viaje debe de estar en revisión');
        viaje.estadoViaje = EstadoViaje.finalizado;
    }

    // Cambio de estado VIAJE revision || finalizado -> novalido
    function novalidTravel() onlyOwner public{
        require (viaje.estadoViaje == EstadoViaje.revision || viaje.estadoViaje == EstadoViaje.finalizado, 'El viaje debe de estar en revisión o finalizado');
        viaje.estadoViaje = EstadoViaje.novalido;
    }

    // Cambio de estado BARCO saliendo -> pescando
    function fishBoat() onlyOwner public{
        require (viaje.estadoBarco == EstadoBarco.saliendo);
        viaje.estadoBarco = EstadoBarco.pescando;
    }

    // Cambio de estado BARCO pescando -> regresando
    function backBoat() onlyOwner public{
        require (viaje.estadoBarco == EstadoBarco.pescando);
        viaje.estadoBarco = EstadoBarco.regresando;
    }

    function compareStrings (string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
       }
    
    // Función para convertir string -> bytes32 ¿?Necesario
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
