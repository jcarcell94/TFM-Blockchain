pragma solidity ^0.5.11; 

contract Barco {
    
    address public barcoDir; // Direccion del contrato
    address public owner; //creador del smartcontract
    Embarcacion barco; 
    // Estructura de datos embarcación
    
    struct Embarcacion{
        string IMO; //ID único de la embarcación ( IMO + 7 digitos) Ej: IMO 8814275
        string modelo; //modelo del barco
        string tipoEmbarcacion; //propósito de la embarcación
        uint eslora; 
        uint manga;
        uint puntal;
        string motor; //tipo de motor
        uint fechaBotadura; //fecha en formato UNIX timestamp
        uint numLicencia; //licencia de explotación del barco
        string puerto; //puerto en el que está registrado el barco
        uint capacidadCarga;
        string bandera; //país en el que está registrado
    }
    
    // Estructura de datos para el tripulante de la embarcación
    
    struct Tripulante{
        string DNI;
        string nombre;
        string apellidos;
        string puesto;
        uint certificado;
    }
    
   Tripulante[] public Tripulacion; 
   mapping (string => bool) Tripulantes; // Mapping de DNI -> Activo
   
   // Eventos
   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   event shipCreated(address indexed owner, address indexed barcoDir);
    
    //Creación del Barco
    constructor (string memory _IMO, string memory _modelo, string memory _tipoEmbarcacion, uint _eslora, uint _manga, uint _puntal, 
    string memory _motor, uint _fechaBotadura, uint _numLicencia, string memory _puerto, uint _capacidadCarga, string memory _bandera) public{

        barcoDir = address(this);
        owner = msg.sender;
        barco = Embarcacion(_IMO, _modelo, _tipoEmbarcacion, _eslora, _manga, _puntal, 
        _motor, _fechaBotadura, _numLicencia, _puerto, _capacidadCarga, _bandera );
        emit shipCreated(owner, barcoDir);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, 'Only owner.');
        _;
    }

    //Información completa del Barco
    function getBarco() public view returns (string memory _IMO, string memory _modelo, string memory _tipoEmbarcacion,  
                                            uint _numLicencia, string memory _puerto, string memory _bandera) {
        Embarcacion memory b = barco;
        return (b.IMO, b.modelo, b.tipoEmbarcacion, b.numLicencia, b.puerto, b.bandera);
    }

    function setPuerto(string memory _puerto) onlyOwner public{
        barco.puerto = _puerto;
    }
    
    function setBandera(string memory _bandera) onlyOwner public{
        barco.bandera = _bandera;
    }

    function anyadirTripulante(string memory _DNI, string memory _nombre, string memory _apellidos, string memory _puesto,  uint _certificado) onlyOwner public {
        // La peticion debe ser enviada por el creador y el tripulante no estar en la lista
        require(!Tripulantes[_DNI]);
        Tripulante memory tripulante;
        tripulante.DNI = _DNI;
        tripulante.nombre = _nombre;
        tripulante.apellidos = _apellidos;
        tripulante.puesto = _puesto;
        tripulante.certificado = _certificado;
        Tripulacion.push(tripulante);
        Tripulantes[_DNI] = true;
    }
    
    function quitarTripulante(string memory _DNI) onlyOwner public {
        // La peticion debe ser enviada por el creador y el tripulante estar en la lista
        require(Tripulantes[_DNI]);
        for (uint i=0;i<Tripulacion.length;i++){
            if(compareStrings(Tripulacion[i].DNI, _DNI)){
                Tripulacion[i] = Tripulacion[Tripulacion.length-1];
                delete Tripulacion[Tripulacion.length-1];
                Tripulacion.length--;
                Tripulantes[_DNI] = false;
                break;
            }
        }
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
