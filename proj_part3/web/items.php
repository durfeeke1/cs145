<?php # items.php - query items by itemid
  session_start();
  include ('./sqlitedb.php');
  include ('./navbar.html');
?>

<html>
  <head>
   <title>AuctionBase</title>
  </head>

  <center>
    <h3> Auction </h3> 
<?php
  if(isset($_SESSION['selectedItem'])){
    /*
    echo " Setting Selected Item";
    echo "<br/>";
    */
    $selectedItem = $_SESSION['selectedItem'];
    $selectedName = $_SESSION['selectedName'];
    $selectedDescription = $_SESSION['selectedDescription'];
    $selectedStarted = $_SESSION['selectedStarted'];
    $selectedEnds = $_SESSION['selectedEnds'];
    $Time = $_SESSION['Time'];
    $selectedStatus = $_SESSION['selectedStatus'];
    $selectedWinner = $_SESSION['selectedWinner'];
    $selectedPrice = $_SESSION['selectedPrice'];
  }
  else{
  
  }
  /*
  echo "<br/>";
  echo "SELCTED ITEM DEFAULT: "."$selectedItem";
  echo "<br/>";
  */
  if(!($_POST["enterCategory"]=="") || 
     !($_POST["enterMaxPrice"]=="") || 
     !($_POST["enterStatus"]=="")){

    try{

      $category = $_POST["enterCategory"];
      $maxPrice = $_POST["enterMaxPrice"];
      $status = $_POST["enterStatus"];
    
      $categoryB = !($category=="");
      $maxPriceB = !($maxPrice=="");
      $statusB = !($status=="");

      $searchConstraints = "";
      $searchArray = array();

      if($categoryB){
        $searchArray[':category'] = $category;
        $searchConstraints = " and Category = :category";
      }
      if($maxPriceB){
        $searchArray[':maxPrice'] = floatval($maxPrice);
        $searchConstraints = "$searchConstraints"." and "."
                                 Currently < :maxPrice";
      }
      if($statusB){
        if($status == "Open"){
          $searchConstraints = "$searchConstraints"." and "."
                                datetime(curr_time) > datetime(Started) and 
                                datetime(curr_time) < datetime(Ends)";
        }
       elseif($status == "Closed"){
         $searchConstraints = "$searchConstraints"." and "."
                                (datetime(curr_time) < datetime(Started) or 
                                datetime(curr_time) > datetime(Ends))";
       } 
       else{
         throw new Exception("Status must be \"Open\" or \"Closed\"");
       }
    }
    
    //Query For Items by selected Attributes
    $com1 = "SELECT DISTINCT Item.ItemID, Name, Currently FROM Item, Price, ItemTime, Time, Categories 
             WHERE Item.ItemID = Price.ItemID and 
                   Item.ItemID = ItemTime.ItemID and
                   Item.ItemID = Categories.ItemID"
                   .$searchConstraints."
             ORDER BY Item.ItemID 
             LIMIT 100";

    /*
    echo "<br/>";
    echo $com1;
    echo "<br/>";
    */

    $result1 = $db->prepare($com1);
    $result1->execute($searchArray);
     
    }catch (Exception $e) {
        try {
          $db->rollBack();
        } catch (PDOException $pe) {}
        echo "Transaction failed: " . $e->getMessage();
        $failure = 1;
    }

   $itemsArrays = $result1->fetchAll();
   
   foreach ($itemsArrays as $i){
      echo "<br/>";
      echo "ItemID: ".htmlspecialchars($i["ItemID"])." ";
      echo "Name: ".htmlspecialchars($i["Name"])." ";
      echo "Current Price: ".htmlspecialchars($i["Currently"])." ";
      echo "<br/>";
   } 

  }
  if(!($_POST["enterItemID"]=="")){
    try{
   
      // Start a transaction
      $db->beginTransaction();

      //Get Item ID from Form
      //$ItemID = '1043374545';
      $ItemID = $_POST["enterItemID"];
      /*
      echo "<br/>";
      echo "ItemID Selected: "."$ItemID";
      echo "<br/>";
      */

      //Query For item by Item ID 
      $com1 = "SELECT * FROM Item WHERE ItemID = :ItemID";
      $result1 = $db->prepare($com1);
      $result1->execute(array(':ItemID' => $ItemID));
 
      $com2 = "SELECT * FROM ItemTime Where ItemID = :ItemID";
      $result2 = $db->prepare($com2);
      $result2->execute(array(':ItemID' => $ItemID));

      $com3 = "SELECT curr_time FROM Time";
      $result3 = $db->prepare($com3);
      $result3->execute();

      $com4 = "SELECT * FROM Bids Where ItemID = :ItemID
               and NOT EXISTS (SELECT * FROM Bids as B2 WHERE B2.ItemID = ItemID 
                                                          and B2.Amount > Amount)";

      $result4 = $db->prepare($com4);
      $result4->execute(array(':ItemID' => $ItemID)); 

      $com5 = "SELECT * FROM Price WHERE ItemID = :ItemID";
      $result5 = $db->prepare($com5);
      $result5->execute(array(':ItemID' => $ItemID));

      //Run Query 
      $db->commit();
      /*
      echo "Success! Query for item issued successfully";
      echo "<br/>";
      */
    }catch (Exception $e) {
        try {
          $db->rollBack();
        } catch (PDOException $pe) {}
        echo "Transaction failed: " . $e->getMessage();
        $failure = 1;
    } 
  
    //Dispaly Result Of Query
    $row = $result1->fetch();
    $selectedItem = htmlspecialchars($row["ItemID"]);
    $selectedName = htmlspecialchars($row["Name"]); 
    $selectedDescription = htmlspecialchars($row["Description"]); 
   
    $timeRow = $result2->fetch();
    $selectedStarted = htmlspecialchars($timeRow["Started"]);
    $selectedEnds = htmlspecialchars($timeRow["Ends"]);

    $currTimeRow = $result3->fetch();
    $Time = htmlspecialchars($currTimeRow["curr_time"]);

    $bidsRow = $result4->fetch();

    $priceRow = $result5->fetch();
    $selectedPrice = htmlspecialchars($priceRow["Currently"]);

    if(!$selectedItem){
      echo "Sorry, there is no item with ItemID: "."$ItemID";
      echo "<br/>";
    }
    else{
      if(strtotime($Time) > strtotime($selectedStarted) && 
         strtotime($Time) < strtotime($selectedEnds)){
            $selectedStatus = "Open";
      }
      else{
         $selectedStatus = "Closed";
         $selectedWinner = htmlspecialchars($bidsRow["BidderID"]);
       }
    }

    $_SESSION['selectedStarted'] = $selectedStarted;
    $_SESSION['selectedEnds'] = $selectedEnds;
    $_SESSION['Time'] = $Time;
    $_SESSION['selectedStatus'] = $selectedStatus;
    $_SESSION['selectedWinner'] = $selectedWinner;
    $_SESSION['selectedItem'] = $selectedItem;
    $_SESSION['selectedName'] = $selectedName;
    $_SESSION['selectedDescription'] = $selectedDescription;
    $_SESSION['selectedPrice'] = $selectedPrice;
    /*
    echo "</br>";
    echo "Session selected Item Set To: ".$_SESSION['selectedItem'];
    echo "</br>";
    */
  }
  if(!($_POST["enterBid"] == "") || !($_POST["enterBidderID"] == "")){
    try{

      //Get Bid from Form
      //$ItemID = '1043374545';
      $Bid = $_POST["enterBid"];
      $BidderID = $_POST["enterBidderID"];
      if(($_POST["enterBid"] == "") || 
         ($_POST["enterBidderID"] == "")){
             throw new Exception("You Must Enter Both UserID and Bid");
         }
      if($selectedStatus == "Closed"){
             throw new Exception("You Cannot Bid On A Closed Auction");
         }
      if($Bid < $selectedPrice){
        throw new Exception("New Bids Must Be Greater Than the Current Asking Price!");
      } 



      // Start a transaction
      $db->beginTransaction();

      $com0 = "SELECT curr_time FROM Time";
      $result0 = $db->prepare($com0);
      $result0->execute();

      $row0 = $result0->fetch();
      $Time = htmlspecialchars($row0["curr_time"]); 
      
      /*
      echo "<br/>";
      echo "UserID :"."$BidderID";
      echo "<br/>";
      echo "Bid Amount: "."$Bid";
      echo "<br/>";
      echo "Current Time: "."$Time";      
      echo "<br/>";
      */

      //Query Insert Bid  
      $com1 = "INSERT INTO Bids ('ItemID','BidderID','ItemTime','Amount') 
               SELECT :ItemID, :BidderID, :Time, :Amount";
      $result1 = $db->prepare($com1);
      $result1->execute(array(':ItemID' => $selectedItem, 
                             ':BidderID' => $BidderID,
                             ':Time' => $Time,
                             ':Amount' => $Bid));
      //Run Query 
      $db->commit();
      
      /* 
      echo "Success! Query to Insert Bid Issued Successfully";
      echo "<br/>";
      */

    }catch (Exception $e) {
        try {
          $db->rollBack();
        } catch (PDOException $pe) {}
        echo "Bid On Item Failed: " . $e->getMessage();
        $failure = 1;
    } 
  
  }
  if(!($failure)){
    if($selectedItem){   
      echo "Selected Item: ";
      echo "<br/>";

      echo "ItemID : "."$selectedItem";
      echo "<br/>";
      echo "Started: "."$selectedStarted"." ";
      echo "Ends: "."$selectedEnds";
      echo "<br/>";
      echo "Current Time: "."$Time";
      echo "<br>";
      echo "Auction Status: "."$selectedStatus";
      echo "<br/>";
      if($selectedWinner){
         echo "Auction Winner: "."$selectedWinner";
         echo "<br/>";
         echo "Price Paid: "."$selectedPrice";
      }
      else{
        echo "Current Asking Price: "."$selectedPrice";
      }
      echo "<br/>";
      echo "Name : "."$selectedName";
      echo "<br/>";
      echo "Description : "."$selectedDescription";
      echo "<br/>";
    }
    if($Bid){
      echo "<br/>";
      echo "Your UserID :"."$BidderID";
      echo "<br/>";
      echo "Your Bid Amount On Selected Item: "."$Bid";
      echo "<br/>";
      echo "Current Time: "."$Time";      
      echo "<br/>";

      echo "Your Bid For The Selected Item : "."$Bid";
      echo "<br/>";
    }
  }
  $db = null;
?>
 <form method="POST" action="items.php">
  <?php
    include ('./browseItem.html');
    include ('./selectitem.html');
    include ('./insertbid.html');
  ?>
  </form>
</center>
</html>

