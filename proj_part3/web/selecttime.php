<html>
<head>
<title>AuctionBase</title>
</head>

<?php # items.php - query items by itemid
  include ('./sqlitedb.php');
?>
<?php 
  include ('./navbar.html');
?>

<center>
<h3> Set a Time </h3> 

  <?php
      $MM = $_POST["MM"];
      $dd = $_POST["dd"];
      $yyyy = $_POST["yyyy"];
      $HH = $_POST["HH"];
      $mm = $_POST["mm"];
      $ss = $_POST["ss"];    
      //$entername = htmlspecialchars($_POST["entername"]);
   
     //Get Current Time From Form 
     if($_POST["MM"]) {
       $selectedTime = $yyyy."-".$MM."-".$dd." ".$HH.":".$mm.":".$ss;
       echo "<center> (Selected time is: ".$selectedTime.".)</center>";
       try{
  
       // Start a transaction
       $db->beginTransaction();
    
       //Query To Insert New Time 
       $com1 = "UPDATE Time SET curr_time = :selectedTime ";
       $result1 = $db->prepare($com1);
       $result1->execute(array(':selectedTime' => $selectedTime));  
       
       //Run Query 
       $db->commit();
       echo "Success! Update for time issued successfully";
       echo "<br/>";
       }catch (Exception $e) {
          try {
            $db->rollBack();
          } catch (PDOException $pe) {}
          echo "Transaction failed: " . $e->getMessage();
        }
  
      $db = null;
    }
  ?>
  <form method="POST" action="selecttime.php">
  <?php 
    echo "<br/>";
    echo "<center>Please select a new time:</center>";
    include ('./timetable.html');
  ?>
  </form>

</center>
</html>
