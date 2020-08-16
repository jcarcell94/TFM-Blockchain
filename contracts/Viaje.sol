pragma solidity ^0.5.11; 

contract Viaje {
    
    address public barcoDir; // Direccion del contrato del barco
    address public viajeDir; // Direccion del contrato del viaje
    address public owner; //creador del smartcontract
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
        string [] localizacion; //localización de la embarcacion (latitud/longitud)
        uint [] timeLocalizacion; //timestamp del registro de la localización
        uint [] horaLocal;  //hora local de la embarcación
        EstadoBarco estadoBarco;
        string [] velRumbo; //velocidad/rumbo
        string [] area; //área geográfica en la que se encuentra
        string [] weather; //estado atmosférico
        
        //noiniciado: smart contract levantado pero el barco no ha salido
        //encurso: el barco se encuentra en proceso de viaje y pesca
        //finalizado: el barco ha finalizado satisfactoriamente el viaje
        //revision: el smart contract se encuentra en proceso de verificación para pasar a finalizado
        //novalido: después de revisado o procesado posteriormente este smart contract queda anulado
        EstadoViaje estadoViaje;
    }


   
   // Eventos
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event travelCreated(address indexed owner, address indexed viajeDir);
    event dataUploaded(address indexed owner, address indexed viajeDir);
    
    //Creación del Viaje
    constructor (uint _ID, string memory _empresa, string memory _puertoIni, string memory _puertoFinalEst, string memory _proposito, address _barcoDir) public{
        viajeDir = address(this);
        barcoDir = _barcoDir;
        owner = msg.sender;
        viaje.ID = _ID;
        viaje.empresa = _empresa;
        viaje.puertoIni = _puertoIni;
        viaje.puertoFinalEst = _puertoFinalEst;
        viaje.puertoFinalReal = "None";
        viaje.proposito = _proposito;
        viaje.localizacion.push("None/None"); 
        viaje.timeLocalizacion.push(0);
        viaje.horaLocal.push(0);
        viaje.estadoBarco = EstadoBarco.amarrado;
        viaje.velRumbo.push("None/None");
        viaje.area.push("None");
        viaje.weather.push("None");
        viaje.estadoViaje= EstadoViaje.noiniciado;
        emit travelCreated(owner, viajeDir);
    }

    function uploadData(string memory _localizacion, uint _timeLocalizacion, uint _horaLocal, string memory _velRumbo, string memory _area, string memory _weather) onlyOwner public{
        require(viaje.estadoViaje == EstadoViaje.encurso, 'El viaje no se encuentra en curso');
        viaje.localizacion.push(_localizacion);
        viaje.timeLocalizacion.push(_timeLocalizacion);
        viaje.horaLocal.push(_horaLocal);
        viaje.velRumbo.push(_velRumbo);
        viaje.area.push(_area);
        viaje.weather.push(_weather);
        emit dataUploaded(owner, viajeDir);
    }

    function getViaje() public view returns (uint _ID, string memory _puertoIni, string memory _proposito, EstadoViaje _estadoViaje, EstadoBarco estadoBarco){
        return (viaje.ID, viaje.puertoIni, viaje.proposito, viaje.estadoViaje, viaje.estadoBarco);
    }

    //Faltaría añadir una funcion que devuelva la traza del barco y otra con la ultima localizacion

    // Cambio de estado VIAJE no iniciado -> en curso
    function startTravel() onlyOwner public{
        require (viaje.estadoViaje == EstadoViaje.noiniciado, 'El viaje debe de estar no iniciado');
        viaje.estadoViaje = EstadoViaje.encurso;
        viaje.estadoBarco = EstadoBarco.saliendo;
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

    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner.');
        _;
    }

    function compareStrings (string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
       }
    
    function renounceOwnership() public onlyOwner { 
        emit OwnershipTransferred(owner, address(0)); owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner); 
    }
    function _transferOwnership(address newOwner) internal {
        require(owner != address(0), "Ownable: new owner is the zero address"); emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
