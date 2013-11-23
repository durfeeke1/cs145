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
    <h3> Browse  Auctions </h3>
 
  <form method="POST" action="browseItems.php">
    <?php
      include ('./browseItems.html');
    ?>
  </form>
<?php

  if(!($_POST["enterCategory"]=="") ||
     !($_POST["enterMaxPrice"]=="") ||
     !($_POST["enterMinPrice"]=="") ||
     !($_POST["enterStatus"]=="")){

    try{

      $category = $_POST["enterCategory"];
      $maxPrice = $_POST["enterMaxPrice"];
      $minPrice = $_POST["enterMinPrice"];
      $status = $_POST["enterStatus"];
      //Allows you to find all strings that contain category
      $category = "%"."$category"."%";

      if((!(is_numeric($maxPrice)) && $maxPrice != "") ||
	 (!(is_numeric($minPrice)) && $minPrice != "")){
        throw new Exception("Max Price and Min Price Must Be A Number");
      }

      $categoryB = !($category=="");
      $maxPriceB = !($maxPrice=="");
      $minPriceB = !($minPrice=="");
      $statusB = !($status=="");

      $searchConstraints = "";
      $searchArray = array();

      if($categoryB){
        $searchArray[':category'] = $category;
        $searchConstraints = " and Category LIKE :category";
      }
      if($maxPriceB){
        $searchArray[':maxPrice'] = floatval($maxPrice);
        $searchConstraints = "$searchConstraints"." and "."
                                 Currently < :maxPrice";
      }
      if($minPriceB){
        $searchArray[':minPrice'] = floatval($minPrice);
        $searchConstraints = "$searchConstraints"." and "."
                                 Currently > :minPrice";
      }
      if($statusB){
        if($status == "Open"){
          $searchConstraints = "$searchConstraints"." and "."
                                datetime(curr_time) > datetime(Started) and 
                                datetime(curr_time) < datetime(Ends) and 
				Currently <> BuyPrice";
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
    $com1 = "SELECT DISTINCT Item.ItemID, Name, Currently, BuyPrice FROM Item, Price, ItemTime, Time, Categories 
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
      echo "<center> ItemID: ".htmlspecialchars($i["ItemID"])." ";
      echo "Name: ".htmlspecialchars($i["Name"])." ";
      echo "Current Price: ".htmlspecialchars($i["Currently"])."</center>";
      echo "<br/>";
   }
  }
 ?>

  </center>
</html>


