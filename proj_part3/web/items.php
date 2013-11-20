<?php # browseItems.php - query items by itemid
  session_start();
  include ('./sqlitedb.php');
  include ('./navbar.html');
?>

<html>
  <head>
   <title>AuctionBase</title>
  </head>

  <center>
    <h3> Auctions </h3> 

 <form method="POST" action="bidItems.php">
  <?php
    include ('./selectitem.html');
  ?>
  </form>

<?php
  if(isset($_SESSION['selectedItem'])){
    $selectedItem = $_SESSION['selectedItem'];
    $selectedName = $_SESSION['selectedName'];
    $selectedDescription = $_SESSION['selectedDescription'];
    $selectedStarted = $_SESSION['selectedStarted'];
    $selectedEnds = $_SESSION['selectedEnds'];
    $Time = $_SESSION['Time'];
    $selectedStatus = $_SESSION['selectedStatus'];
    $selectedWinner = $_SESSION['selectedWinner'];
    $selectedPrice = $_SESSION['selectedPrice'];
    $selectedBuyPrice = $_SESSION['selectedBuyPrice'];
    $selectedBidsArray = $_SESSION['selectedBidsArray'];
    $selectedFirstBid = $_SESSION['selectedFirstBid'];
  }
 
  if(!($_POST["enterBid"] == "") || 
     !($_POST["enterBidderID"] == "")){
    try{

      //Get Bid from Form
      $Bid = $_POST["enterBid"];
      //Convert Bid to Float
      $Bid = floatval($Bid);
      //Round
      $Bid = round($Bid,2);
      
      //Get Bidder ID From Form
      $BidderID = $_POST["enterBidderID"];
      
      //Make sure Both Are Given
      if(($_POST["enterBid"] == "") || 
         ($_POST["enterBidderID"] == "")){
             throw new Exception("You Must Enter Both UserID and Bid");
         }
      //Make Sure Auction Being Bid On Is Open
      if($selectedStatus == "Closed"){
             throw new Exception("You Cannot Bid On A Closed Auction");
         }
      //Make Sure New Bid Is Larger Than Asking Price
      if($Bid <= $selectedPrice){
        throw new Exception("New Bids Must Be Greater Than the Current Asking Price!");
      } 
      //Make sure New Bid Is Later Than Old Bid
      //NOTE: This does not need to be handled if time is only allowed to go forward

      // Start a transaction
      $db->beginTransaction();

      $com0 = "SELECT curr_time FROM Time";
      $result0 = $db->prepare($com0);
      $result0->execute();

      $row0 = $result0->fetch();
      $Time = htmlspecialchars($row0["curr_time"]); 
      
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
      
    }catch (Exception $e) {
        try {
          $db->rollBack();
        } catch (PDOException $pe) {}
        echo "Bid On Item Failed: " . $e->getMessage();
        $failure = 1;
    } 
  
  }

  if(!($_POST["enterItemID"]=="")||
     (!($_POST["enterBid"] == "") &&
     !($_POST["enterBidderID"] == ""))){
    try{
   
      // Start a transaction
      $db->beginTransaction();

      //Used Session ItemID If It Is Blank During Bid
      if(!($_POST["enterBid"] == "") && 
          ($_POST["enterItemID"]=="")){
        $ItemID = $selectedItem;
      }
      //Otherwise Get From Form
      else{
        $ItemID = $_POST["enterItemID"];
      }

      //Query For item by Item ID 
      $com1 = "SELECT * FROM Item WHERE ItemID = :ItemID";
      $result1 = $db->prepare($com1);
      $result1->execute(array(':ItemID' => $ItemID));
      //Query for ItemTime By ItemID 
      $com2 = "SELECT * FROM ItemTime Where ItemID = :ItemID";
      $result2 = $db->prepare($com2);
      $result2->execute(array(':ItemID' => $ItemID));
      //Query For Current Time
      $com3 = "SELECT curr_time FROM Time";
      $result3 = $db->prepare($com3);
      $result3->execute();
      //Query For Bid Of Winner
      $com4 = "SELECT * FROM Bids WHERE ItemID = :ItemID
               and NOT EXISTS (SELECT * FROM Bids as B2 WHERE B2.ItemID = Bids.ItemID 
                                                          and B2.Amount > Bids.Amount)";
      $result4 = $db->prepare($com4);
      $result4->execute(array(':ItemID' => $ItemID)); 
      //Query For Price Attributes By ItemID
      $com5 = "SELECT * FROM Price WHERE ItemID = :ItemID";
      $result5 = $db->prepare($com5);
      $result5->execute(array(':ItemID' => $ItemID));
      //Query For All Bids By ItemID
      $com6 = "SELECT * FROM Bids WHERE ItemID = :ItemID ORDER BY Amount LIMIT 100";
      $result6 = $db->prepare($com6);
      $result6->execute(array(':ItemID' => $ItemID));

      //Run Query 
      $db->commit();
    
    }catch (Exception $e) {
        try {
          $db->rollBack();
        } catch (PDOException $pe) {}
        echo "Transaction failed: " . $e->getMessage();
        $failure = 1;
    } 
  
    //Display Result Of Query
    $row = $result1->fetch();
    $selectedItem = htmlspecialchars($row["ItemID"]);
    $selectedName = htmlspecialchars($row["Name"]); 
    $selectedDescription = htmlspecialchars($row["Description"]); 
   
    $timeRow = $result2->fetch();
    $selectedStarted = htmlspecialchars($timeRow["Started"]);
    $selectedEnds = htmlspecialchars($timeRow["Ends"]);

    $currTimeRow = $result3->fetch();
    $Time = htmlspecialchars($currTimeRow["curr_time"]);

    $winnerRow = $result4->fetch();

    $priceRow = $result5->fetch();
    $selectedPrice = htmlspecialchars($priceRow["Currently"]);
    $selectedBuyPrice = htmlspecialchars($priceRow["BuyPrice"]);
    $selectedFirstBid = htmlspecialchars($priceRow["FirstBid"]);

    $selectedBidsArray = $result6->fetchAll();

    if(!$selectedItem){
      echo "Sorry, there is no item with ItemID: "."$ItemID";
      echo "<br/>";
    }
    else{
      //Current Time Must Be Between Start and End Time of Auction
      if(strtotime($Time) > strtotime($selectedStarted) && 
         strtotime($Time) < strtotime($selectedEnds)){
        //If Buy Price Is Matched Then The Auction Is Closed
        if($selectedPrice == $selectedBuyPrice){
          $selectedStatus = "Closed";
        }
        else{
          $selectedStatus = "Open";
        }
      }
      else{
        $selectedStatus = "Closed";
      }
      //Only Display Winnder If the Auction Is Closed 
      if($selectedStatus == "Closed"){
        $selectedWinner = htmlspecialchars($winnerRow["BidderID"]);
        if(!($selectedWinner)){
          $selectedWinnder = "No One Bid On Item :(";
         }
      }
      else{
        $selectedWinner = "";
      }
    }
    
    //Set Session Variables
    $_SESSION['selectedStarted'] = $selectedStarted;
    $_SESSION['selectedEnds'] = $selectedEnds;
    $_SESSION['Time'] = $Time;
    $_SESSION['selectedStatus'] = $selectedStatus;
    $_SESSION['selectedWinner'] = $selectedWinner;
    $_SESSION['selectedItem'] = $selectedItem;
    $_SESSION['selectedName'] = $selectedName;
    $_SESSION['selectedDescription'] = $selectedDescription;
    $_SESSION['selectedPrice'] = $selectedPrice;
    $_SESSION['selectedBuyPrice'] = $selectedBuyPrice;
    $_SESSION['selectedFirstBid'] = $selectedFirstBid;
    $_SESSION['selectedBidsArray'] = $selectedBidsArray;
  }
  if(!($failure)){
    if($selectedItem){   
      echo "SELECTED ITEM: ";
      echo "<br/>";
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
        echo "First Bid: "."$selectedFirstBid ";
        echo "Current Asking Price: "."$selectedPrice ";
        if($selectedBuyPrice){
          echo "Buy Price: "."$selectedBuyPrice";
        }
      }
      echo "<br/>";
      echo "Name : "."$selectedName";
      echo "<br/>";
      echo "Description : "."$selectedDescription";
      echo "<br/>";
      echo "<br/>";
      echo "BIDS ON SELECTED ITEM:";
      echo "<br/>";
      if($selectedBidsArray){
        foreach ($selectedBidsArray as $i){
          echo "<br/>";
          echo "Bidder: ".htmlspecialchars($i["BidderID"])." ";
          echo "Time: ".htmlspecialchars($i["ItemTime"])." ";
          if($selectedWinner){
            echo "Price Paid: ".htmlspecialchars($i["Amount"])." ";
          }else{
            echo "Bid Amount: ".htmlspecialchars($i["Amount"])." ";
            echo "<br/>";
          }
        }
      }
      else{
        echo "No Bids Yet..";
      }
    }
  }
 ?>

 <form method="POST" action="bidItems.php">
  <?php
    //include ('./browseItem.html');
    //include ('./selectitem.html');
    include ('./insertbid.html');
  ?>
  </form>

  <?php
    /*if($Bid){
      echo "<br/>";
      echo "Your UserID :"."$BidderID";
      echo "<br/>";
      echo "Your Bid Amount On Selected Item: "."$Bid";
      echo "<br/>";
      echo "Current Time: "."$Time";      
      echo "<br/>";
    }
    */
  $db = null;
  ?>

</center>
</html>
