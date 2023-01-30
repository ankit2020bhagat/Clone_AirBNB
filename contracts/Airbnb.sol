// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
pragma solidity ^0.8.0;

contract AirBNB is Ownable{
    using Counters for Counters.Counter; 
    Counters.Counter private _tokenIdCounter;

    struct PropertyDetails {
        address propertyOwner;
        string details;
        bool isBooked;
        uint PricePerDay;
        

    }


    struct BookingDetails{
        uint propertyId;
        address customerAddress;
        uint duration;
        uint startTimeStamp;
        uint endTimeStamp;
        uint bookingAmount;
    }
    

    /// only owner can call this function
    error onlyowner();

    ///property is booked
    error checkStatus();

    ///not having enough ether
    error insufficientBalance();

    ///failed to send balance
    error failedToTrnasfer();

    ///only customer can call this function
    error onlyCustomer();

    event addProperty(address propertyOwner,string details,
    bool isBooked,uint PricePerDay);

    event bookProperty(
        uint propertyId,address customerAddress,
        uint duration,uint startTimeStamp,uint endTimeStamp,
        uint amount);
    

    modifier isBooked(uint propertyId){
        PropertyDetails memory property = PropertyDetailsId[propertyId];
        if( property.isBooked){
            revert checkStatus();
        }
        _;
    }

    modifier OnlyOwner(uint propertyId){
        PropertyDetails memory property = PropertyDetailsId[propertyId];
        if(property.propertyOwner != msg.sender){
              revert onlyowner();
        }
        _;
    }

    modifier onlycustomerOwner(address customerAddress){
        BookingDetails memory _bookingdetails = bookingdetails[customerAddress];
        if(_bookingdetails.customerAddress!=customerAddress){
            revert onlyCustomer();
        }
        _; 
    }

    mapping (address => BookingDetails) public bookingdetails;
    mapping (uint =>PropertyDetails) public PropertyDetailsId;
    

   
    function addPropety(string memory propertDetails,
    uint _peicePerDay) external {
        _tokenIdCounter.increment();
        uint count = _tokenIdCounter.current();
        PropertyDetails storage addnewProPerty = PropertyDetailsId[count];
        addnewProPerty.propertyOwner = msg.sender;
        addnewProPerty.details= propertDetails;
        addnewProPerty.isBooked= false;
        addnewProPerty.PricePerDay = _peicePerDay;
        
        emit addProperty(addnewProPerty.propertyOwner,addnewProPerty.details
        ,addnewProPerty.isBooked,addnewProPerty.PricePerDay);
        

    }

    function createBook(uint propertyId,uint duration) external payable isBooked(propertyId){
       PropertyDetails storage property = PropertyDetailsId[propertyId];
       if(msg.value<property.PricePerDay * duration){
           revert insufficientBalance();
       }
       property.isBooked = true;
      

     //  bookedProperty[msg.sender] = PropertyDetailsId[propertyId];
       BookingDetails storage _bookingdetails = bookingdetails[msg.sender];
      
       _bookingdetails.propertyId = propertyId;
       _bookingdetails.customerAddress = msg.sender;
       _bookingdetails.duration = duration;
       _bookingdetails.startTimeStamp = block.timestamp;
       _bookingdetails.endTimeStamp = block.timestamp + duration;
       uint amount  = (address(this).balance * 5)/100;
       (bool success,) = owner().call{value:amount}("");
       if(!success){
          revert failedToTrnasfer();
       }
       _bookingdetails.bookingAmount = msg.value ;

       emit bookProperty(_bookingdetails.propertyId,
       _bookingdetails.customerAddress,
       _bookingdetails.duration,
       _bookingdetails.startTimeStamp,
       _bookingdetails.endTimeStamp,
       _bookingdetails.bookingAmount);
    }

    function updatePropertyDetailes (
        uint propertyId,string memory
        _propertyDetails,uint _pricePerDay) external OnlyOwner( propertyId) isBooked(propertyId){
        PropertyDetails storage updateproperty = PropertyDetailsId[propertyId];
        //updateproperty.propertyOwner = newOwner;
        updateproperty.details = _propertyDetails;
       // updateproperty.isBooked=_isBooked;
        updateproperty.PricePerDay = _pricePerDay;
    }

    function cancelBooking(address bookingId) external onlycustomerOwner(bookingId){
         BookingDetails storage _bookingdetails = bookingdetails[bookingId];
         PropertyDetails memory _propertyDetails = PropertyDetailsId[_bookingdetails.propertyId];
         uint dutationleft = _bookingdetails.endTimeStamp - _bookingdetails.startTimeStamp;
         uint amountRemain =  _bookingdetails.bookingAmount - dutationleft * _propertyDetails.PricePerDay;
         (bool success,) = _bookingdetails.customerAddress.call{value:amountRemain}("");
         if(!success){
             revert failedToTrnasfer();
         }
         delete bookingdetails[bookingId];
    }

    function transfermoneyTopropertyOwner(uint propertyId,uint amount) internal isBooked(propertyId){
        PropertyDetails storage property = PropertyDetailsId[propertyId];
        if(property.propertyOwner != msg.sender){
            revert onlyowner();
        }
       
        address PropertyOwner = property.propertyOwner;
        
        (bool sucess,) =PropertyOwner.call{value:amount}("");
        if(!sucess){
            revert failedToTrnasfer(); 
        }
    }

    // function withdraw() external onlyOwner{
    //     uint amount  = (address(this).balance * 5)/100;
    //   (bool success,) = owner().call{value:amount}("");
    //   if(!success){
    //       revert failedToTrnasfer();
    //   }
    // }

    function delistProperty(uint propertyId) external OnlyOwner(propertyId){
           delete PropertyDetailsId[propertyId];
    }

    function getListofAllProperty() external returns(PropertyDetails[] memory,uint){
        uint count = _tokenIdCounter.current();
        PropertyDetails[] memory property = new PropertyDetails[](count);
        
        for(uint i=0;i<_tokenIdCounter.current();i++) {
             PropertyDetails storage propertylist = PropertyDetailsId[i];
             property[i] = propertylist;
        }

        return property,property.length;
    }


    function checkAndreturn(address bookingId) external {
        BookingDetails storage bookingDetails = bookingdetails[bookingId];

        if (block.timestamp<bookingDetails.endTimeStamp){
            revert();
        }
          uint amount = bookingDetails.bookingAmount;
        transfermoneyTopropertyOwner(bookingDetails.propertyId,amount);
        

    }

    
} 